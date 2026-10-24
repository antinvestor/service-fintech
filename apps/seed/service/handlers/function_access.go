// Copyright 2023-2026 Ant Investor Ltd
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

package handlers

import (
	"context"
	"errors"
	"fmt"
	"net/http"
	"regexp"
	"strings"

	"github.com/antinvestor/common/v3/permissions"
	"github.com/pitabwire/frame/v3/security/authorizer"
	"github.com/pitabwire/util"
	"google.golang.org/genproto/googleapis/api/annotations"
	"google.golang.org/protobuf/proto"
	"google.golang.org/protobuf/reflect/protoreflect"
	"google.golang.org/protobuf/types/descriptorpb"
)

// RoutePermissions maps a route key (see RouteKey) to the permissions a
// caller must hold, all of them, before the route's handler runs.
type RoutePermissions map[string][]string

// PermissionChecker is the part of *authorizer.FunctionChecker the middleware
// depends on, so tests can substitute a checker that does not talk to Keto.
type PermissionChecker interface {
	Check(ctx context.Context, permission string) error
}

// pathVariable matches one {name} or {name...} segment of a mux pattern or a
// google.api.http path template.
var pathVariable = regexp.MustCompile(`\{[^}]*\}`)

// RouteKey normalises an HTTP method and a path template into the key both
// the manifest and the mux resolve to. Variable names differ between the
// proto ({group_id}) and the mux ({groupId}), so every variable collapses to
// {}.
func RouteKey(method, path string) string {
	return strings.ToUpper(method) + " " + pathVariable.ReplaceAllString(path, "{}")
}

// BuildRoutePermissions reads the google.api.http binding and the
// common.v1.method_permissions of every RPC on the manifest service and
// returns the route → permissions map. It fails when a method has no HTTP
// binding or names no permission, so a manifest entry can never silently
// become an open route.
func BuildRoutePermissions(sd protoreflect.ServiceDescriptor) (RoutePermissions, error) {
	methods := sd.Methods()
	routes := make(RoutePermissions, methods.Len())
	for i := range methods.Len() {
		md := methods.Get(i)

		httpMethod, path, err := httpBinding(md)
		if err != nil {
			return nil, err
		}
		perms := permissions.ForMethod(md).Permissions
		if len(perms) == 0 {
			return nil, fmt.Errorf("manifest method %s names no permission", md.FullName())
		}

		key := RouteKey(httpMethod, path)
		if _, dup := routes[key]; dup {
			return nil, fmt.Errorf("manifest method %s duplicates route %q", md.FullName(), key)
		}
		routes[key] = perms
		// The same method served over Connect (peer services) carries the
		// same permissions.
		routes[RouteKey(http.MethodPost, ConnectProcedure(sd, md))] = perms
	}
	return routes, nil
}

// ConnectProcedure is the Connect path of a manifest method.
func ConnectProcedure(sd protoreflect.ServiceDescriptor, md protoreflect.MethodDescriptor) string {
	return "/" + string(sd.FullName()) + "/" + string(md.Name())
}

func httpBinding(md protoreflect.MethodDescriptor) (string, string, error) {
	opts, ok := md.Options().(*descriptorpb.MethodOptions)
	if !ok || opts == nil {
		return "", "", fmt.Errorf("manifest method %s has no options", md.FullName())
	}
	rule, ok := proto.GetExtension(opts, annotations.E_Http).(*annotations.HttpRule)
	if !ok || rule == nil {
		return "", "", fmt.Errorf("manifest method %s has no google.api.http binding", md.FullName())
	}

	switch pattern := rule.GetPattern().(type) {
	case *annotations.HttpRule_Get:
		return http.MethodGet, pattern.Get, nil
	case *annotations.HttpRule_Post:
		return http.MethodPost, pattern.Post, nil
	case *annotations.HttpRule_Put:
		return http.MethodPut, pattern.Put, nil
	case *annotations.HttpRule_Patch:
		return http.MethodPatch, pattern.Patch, nil
	case *annotations.HttpRule_Delete:
		return http.MethodDelete, pattern.Delete, nil
	case *annotations.HttpRule_Custom:
		return pattern.Custom.GetKind(), pattern.Custom.GetPath(), nil
	default:
		return "", "", fmt.Errorf("manifest method %s has an empty google.api.http binding", md.FullName())
	}
}

// FunctionAccessMiddleware enforces the manifest's route permissions in front
// of the mux. It resolves the route the mux would serve, looks its key up in
// routes and checks every permission through checker.
//
// A registered route that is missing from the manifest is refused with 403:
// the manifest is the source of truth, and an unmapped route is a deployment
// mistake, never an open endpoint. A request that matches no route at all is
// handed to the mux so it can answer 404 or 405 as usual.
//
// Place it after AuthenticationMiddleware and TenancyAccessMiddleware so the
// claims the checker reads are already in the context.
func FunctionAccessMiddleware(mux *http.ServeMux, checker PermissionChecker, routes RoutePermissions) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		ctx := r.Context()

		_, pattern := mux.Handler(r)
		if pattern == "" {
			mux.ServeHTTP(w, r)
			return
		}

		key := routeKeyFromPattern(pattern, r.Method)
		perms, mapped := routes[key]
		if !mapped {
			util.Log(ctx).WithField("route", key).Error("route is not in the permission manifest; refusing")
			writeJSON(ctx, w, http.StatusForbidden, errorBody{
				Error: "this route is not authorised for use",
			})
			return
		}

		for _, perm := range perms {
			if err := checker.Check(ctx, perm); err != nil {
				writeAccessError(ctx, w, key, perm, err)
				return
			}
		}

		mux.ServeHTTP(w, r)
	})
}

// routeKeyFromPattern turns the pattern the mux matched (for example
// "POST /api/v1/groups/{groupId}/welcome") into a RouteKey. A pattern without
// a method matches every method, so the request's own method is used.
func routeKeyFromPattern(pattern, requestMethod string) string {
	method, path, found := strings.Cut(pattern, " ")
	if !found {
		return RouteKey(requestMethod, pattern)
	}
	return RouteKey(method, path)
}

func writeAccessError(ctx context.Context, w http.ResponseWriter, route, permission string, err error) {
	status := authorizer.ToHTTPStatusCode(err)
	log := util.Log(ctx).WithField("route", route).WithField("permission", permission).WithError(err)

	var message string
	switch status {
	case http.StatusUnauthorized:
		log.Info("function access refused: no authenticated principal")
		message = "an authenticated caller is required"
	case http.StatusForbidden:
		log.Info("function access refused: permission denied")
		message = "the caller lacks the permission this route requires"
	default:
		log.Error("function access check failed")
		status = http.StatusServiceUnavailable
		message = "authorisation is temporarily unavailable"
	}

	if errors.Is(ctx.Err(), context.Canceled) {
		return
	}
	writeJSON(ctx, w, status, errorBody{Error: message})
}
