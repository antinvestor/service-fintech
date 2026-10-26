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

// Package ussd is Seed's side of the borrower USSD menu: it registers the
// menu with the service-notification USSD engine, pushes what each borrower
// sees, and opens the secrets (PINs) the engine seals for Seed.
package ussd

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"strings"
)

// maxErrorBody bounds how much of an error answer is kept for the message.
const maxErrorBody = 512

// Client talks to the USSD engine's management API as Seed's service
// account. The HTTP client carries Seed's OAuth token (Frame's client
// manager); the engine admits service accounts only.
type Client struct {
	baseURL string
	http    *http.Client
}

// NewClient returns a client for the engine at baseURL, or nil when no URL
// is configured (USSD off).
func NewClient(baseURL string, httpClient *http.Client) *Client {
	baseURL = strings.TrimRight(strings.TrimSpace(baseURL), "/")
	if baseURL == "" || httpClient == nil {
		return nil
	}
	return &Client{baseURL: baseURL, http: httpClient}
}

// Menu is one node of a menu tree as the engine stores it.
type Menu struct {
	ID            string `json:"id,omitempty"`
	ParentID      string `json:"parent_id,omitempty"`
	Order         int    `json:"order"`
	Action        string `json:"action"`
	Validator     string `json:"validator,omitempty"`
	Name          string `json:"name"`
	Message       string `json:"message"`
	CollectionKey string `json:"collection_key,omitempty"`
	Extra         string `json:"extra,omitempty"`
	Regex         string `json:"regex,omitempty"`
	ErrorMessage  string `json:"error_message,omitempty"`
	IsSecret      bool   `json:"is_secret,omitempty"`
}

// RootMenus lists the trees Seed owns.
func (c *Client) RootMenus(ctx context.Context) ([]Menu, error) {
	var out []Menu
	err := c.do(ctx, http.MethodGet, "/api/v1/menus", nil, &out)
	return out, err
}

// CreateMenu stores a node and returns its id.
func (c *Client) CreateMenu(ctx context.Context, m Menu) (string, error) {
	var created struct {
		ID string `json:"id"`
	}
	if err := c.do(ctx, http.MethodPost, "/api/v1/menus", m, &created); err != nil {
		return "", err
	}
	if created.ID == "" {
		return "", fmt.Errorf("ussd: menu %q created without an id", m.Name)
	}
	return created.ID, nil
}

// DeleteMenu removes a node and everything under it.
func (c *Client) DeleteMenu(ctx context.Context, id string) error {
	return c.do(ctx, http.MethodDelete, "/api/v1/menus/"+id, nil, nil)
}

// SetConfig sets one setting of a gateway service.
func (c *Client) SetConfig(ctx context.Context, serviceID, name, value string) error {
	return c.do(ctx, http.MethodPut, "/api/v1/services/"+serviceID+"/config",
		map[string]string{"name": name, "value": value}, nil)
}

func (c *Client) do(ctx context.Context, method, path string, in, out any) error {
	var body io.Reader
	if in != nil {
		raw, err := json.Marshal(in)
		if err != nil {
			return fmt.Errorf("ussd: encode %s %s: %w", method, path, err)
		}
		body = bytes.NewReader(raw)
	}
	req, err := http.NewRequestWithContext(ctx, method, c.baseURL+path, body)
	if err != nil {
		return fmt.Errorf("ussd: build %s %s: %w", method, path, err)
	}
	if in != nil {
		req.Header.Set("Content-Type", "application/json")
	}
	resp, err := c.http.Do(req)
	if err != nil {
		return fmt.Errorf("ussd: %s %s: %w", method, path, err)
	}
	defer func() { _ = resp.Body.Close() }()
	if resp.StatusCode >= http.StatusBadRequest {
		msg, _ := io.ReadAll(io.LimitReader(resp.Body, maxErrorBody))
		return fmt.Errorf("ussd: %s %s: %s: %s", method, path, resp.Status, strings.TrimSpace(string(msg)))
	}
	if out == nil {
		return nil
	}
	if err = json.NewDecoder(resp.Body).Decode(out); err != nil {
		return fmt.Errorf("ussd: decode %s %s: %w", method, path, err)
	}
	return nil
}
