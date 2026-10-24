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

package main

import (
	"context"

	connectv1 "connectrpc.com/connect"
	"connectrpc.com/connect/v2"
	"github.com/antinvestor/service-trustage/client/workflows"
	workflowv1 "github.com/antinvestor/service-trustage/gen/go/workflow/v1"
	"github.com/antinvestor/service-trustage/gen/go/workflow/v1/workflowv1connect"
	"google.golang.org/protobuf/reflect/protoreflect"
)

// trustageWorkflows carries trustage's workflow messages over a connect v2
// client. Trustage still publishes its SDK and its workflow loader for
// connect v1, and its messages cannot be swapped for the BSR build of the
// same protos (the files would register twice). The bridge keeps trustage's
// own types and loader while the transport, authentication included, is the
// connect v2 client every other peer of this service uses. Drop it once
// trustage ships a connect v2 SDK.
type trustageWorkflows struct {
	client  *connect.Client
	service protoreflect.ServiceDescriptor
}

var _ workflows.WorkflowClient = trustageWorkflows{}

func newTrustageWorkflows(client *connect.Client) trustageWorkflows {
	return trustageWorkflows{
		client:  client,
		service: workflowv1.File_v1_workflow_proto.Services().ByName("WorkflowService"),
	}
}

func (t trustageWorkflows) call(ctx context.Context, procedure, method string, req, res any) error {
	spec := connect.Spec{
		StreamType: connect.StreamTypeUnary,
		Procedure:  procedure,
		Schema:     t.service.Methods().ByName(protoreflect.Name(method)),
	}
	return t.client.CallUnary(ctx, spec, req, res)
}

func (t trustageWorkflows) ListWorkflows(
	ctx context.Context,
	req *connectv1.Request[workflowv1.ListWorkflowsRequest],
) (*connectv1.Response[workflowv1.ListWorkflowsResponse], error) {
	res := &workflowv1.ListWorkflowsResponse{}
	if err := t.call(
		ctx,
		workflowv1connect.WorkflowServiceListWorkflowsProcedure,
		"ListWorkflows",
		req.Msg,
		res,
	); err != nil {
		return nil, err
	}
	return connectv1.NewResponse(res), nil
}

func (t trustageWorkflows) CreateWorkflow(
	ctx context.Context,
	req *connectv1.Request[workflowv1.CreateWorkflowRequest],
) (*connectv1.Response[workflowv1.CreateWorkflowResponse], error) {
	res := &workflowv1.CreateWorkflowResponse{}
	if err := t.call(
		ctx,
		workflowv1connect.WorkflowServiceCreateWorkflowProcedure,
		"CreateWorkflow",
		req.Msg,
		res,
	); err != nil {
		return nil, err
	}
	return connectv1.NewResponse(res), nil
}

func (t trustageWorkflows) ActivateWorkflow(
	ctx context.Context,
	req *connectv1.Request[workflowv1.ActivateWorkflowRequest],
) (*connectv1.Response[workflowv1.ActivateWorkflowResponse], error) {
	res := &workflowv1.ActivateWorkflowResponse{}
	if err := t.call(
		ctx,
		workflowv1connect.WorkflowServiceActivateWorkflowProcedure,
		"ActivateWorkflow",
		req.Msg,
		res,
	); err != nil {
		return nil, err
	}
	return connectv1.NewResponse(res), nil
}
