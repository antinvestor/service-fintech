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
	"fmt"
	"os"
	"text/tabwriter"

	limitsv1 "buf.build/gen/go/antinvestor/limits/protocolbuffers/go/limits/v1"
	"connectrpc.com/connect"
	"github.com/spf13/cobra"
	"google.golang.org/protobuf/encoding/protojson"
)

func policiesCmd() *cobra.Command {
	cmd := &cobra.Command{
		Use:   "policies",
		Short: "Manage limit policies",
	}

	cmd.AddCommand(policiesListCmd())
	cmd.AddCommand(policiesShowCmd())
	cmd.AddCommand(policiesEnableCmd())
	cmd.AddCommand(policiesDisableCmd())

	return cmd
}

// tabPadding is the cell padding used for tabwriter output.
const tabPadding = 2

//nolint:gocognit // sequential CLI flag mapping and output formatting reads clearer inline
func policiesListCmd() *cobra.Command {
	var (
		flagQuery  string
		flagAction string
		flagMode   string
	)

	cmd := &cobra.Command{
		Use:   "list",
		Short: "List limit policies",
		RunE: func(cmd *cobra.Command, _ []string) error {
			client, err := newAdminClient(cmd.Context())
			if err != nil {
				return fmt.Errorf("build client: %w", err)
			}
			req := &limitsv1.PolicySearchRequest{}

			if flagQuery != "" {
				req.Query = flagQuery
			}

			// Map --action flag to LimitAction enum.
			if flagAction != "" {
				v, ok := limitsv1.LimitAction_value[flagAction]
				if !ok {
					return fmt.Errorf("unknown action %q", flagAction)
				}
				req.Action = limitsv1.LimitAction(v)
			}

			// Map --mode flag to PolicyMode enum.
			if flagMode != "" {
				v, ok := limitsv1.PolicyMode_value[flagMode]
				if !ok {
					return fmt.Errorf(
						"unknown mode %q; valid values: POLICY_MODE_OFF, POLICY_MODE_SHADOW, POLICY_MODE_ENFORCE",
						flagMode,
					)
				}
				req.Mode = limitsv1.PolicyMode(v)
			}

			stream, err := client.PolicySearch(cmd.Context(), connect.NewRequest(req))
			if err != nil {
				return fmt.Errorf("PolicySearch: %w", err)
			}

			var policies []*limitsv1.PolicyObject
			for stream.Receive() {
				policies = append(policies, stream.Msg().GetData()...)
			}
			if streamErr := stream.Err(); streamErr != nil {
				return fmt.Errorf("stream error: %w", streamErr)
			}

			if flagJSON {
				mo := protojson.MarshalOptions{Indent: "  "}
				for _, p := range policies {
					out, marshalErr := mo.Marshal(p)
					if marshalErr != nil {
						return marshalErr
					}
					fmt.Fprintln(os.Stdout, string(out))
				}
				return nil
			}

			w := tabwriter.NewWriter(os.Stdout, 0, 0, tabPadding, ' ', 0)
			fmt.Fprintln(w, "ID\tSCOPE\tACTION\tMODE\tCURRENCY\tNOTES")
			for _, p := range policies {
				fmt.Fprintf(w, "%s\t%s\t%s\t%s\t%s\t%s\n",
					p.GetId(),
					p.GetScope().String(),
					p.GetAction().String(),
					p.GetMode().String(),
					p.GetCurrencyCode(),
					p.GetNotes(),
				)
			}
			return w.Flush()
		},
	}

	cmd.Flags().StringVar(&flagQuery, "query", "", "Filter by free-text query (tenant, org, or policy name)")
	cmd.Flags().StringVar(&flagAction, "action", "", "Filter by limit action (e.g. LIMIT_ACTION_LOAN_DISBURSEMENT)")
	cmd.Flags().StringVar(&flagMode, "mode", "", "Filter by policy mode (e.g. POLICY_MODE_ENFORCE)")

	return cmd
}

func policiesShowCmd() *cobra.Command {
	return &cobra.Command{
		Use:   "show <id>",
		Short: "Show a single policy",
		Args:  cobra.ExactArgs(1),
		RunE: func(cmd *cobra.Command, args []string) error {
			client, err := newAdminClient(cmd.Context())
			if err != nil {
				return fmt.Errorf("build client: %w", err)
			}
			resp, err := client.PolicyGet(cmd.Context(), connect.NewRequest(&limitsv1.PolicyGetRequest{
				Id: args[0],
			}))
			if err != nil {
				return fmt.Errorf("PolicyGet: %w", err)
			}

			p := resp.Msg.GetData()
			if flagJSON {
				out, marshalErr := protojson.MarshalOptions{Indent: "  "}.Marshal(p)
				if marshalErr != nil {
					return marshalErr
				}
				fmt.Fprintln(os.Stdout, string(out))
				return nil
			}

			w := tabwriter.NewWriter(os.Stdout, 0, 0, tabPadding, ' ', 0)
			fmt.Fprintf(w, "ID:\t%s\n", p.GetId())
			fmt.Fprintf(w, "Scope:\t%s\n", p.GetScope().String())
			fmt.Fprintf(w, "Action:\t%s\n", p.GetAction().String())
			fmt.Fprintf(w, "Mode:\t%s\n", p.GetMode().String())
			fmt.Fprintf(w, "Currency:\t%s\n", p.GetCurrencyCode())
			fmt.Fprintf(w, "LimitKind:\t%s\n", p.GetLimitKind().String())
			fmt.Fprintf(w, "SubjectType:\t%s\n", p.GetSubjectType().String())
			if amt := p.GetCapAmount(); amt != nil {
				fmt.Fprintf(w, "CapAmount:\t%d %s\n", amt.GetUnits(), amt.GetCurrencyCode())
			}
			if p.GetCapCount() > 0 {
				fmt.Fprintf(w, "CapCount:\t%d\n", p.GetCapCount())
			}
			fmt.Fprintf(w, "Version:\t%d\n", p.GetVersion())
			fmt.Fprintf(w, "Notes:\t%s\n", p.GetNotes())
			return w.Flush()
		},
	}
}

func policiesEnableCmd() *cobra.Command {
	return &cobra.Command{
		Use:   "enable <id>",
		Short: "Enable a policy (set mode to POLICY_MODE_ENFORCE)",
		Args:  cobra.ExactArgs(1),
		RunE: func(cmd *cobra.Command, args []string) error {
			return togglePolicyMode(cmd.Context(), args[0], limitsv1.PolicyMode_POLICY_MODE_ENFORCE)
		},
	}
}

func policiesDisableCmd() *cobra.Command {
	return &cobra.Command{
		Use:   "disable <id>",
		Short: "Disable a policy (set mode to POLICY_MODE_OFF)",
		Args:  cobra.ExactArgs(1),
		RunE: func(cmd *cobra.Command, args []string) error {
			return togglePolicyMode(cmd.Context(), args[0], limitsv1.PolicyMode_POLICY_MODE_OFF)
		},
	}
}

// togglePolicyMode fetches the policy, sets its mode, and saves it back.
func togglePolicyMode(ctx context.Context, id string, mode limitsv1.PolicyMode) error {
	client, err := newAdminClient(ctx)
	if err != nil {
		return fmt.Errorf("build client: %w", err)
	}

	getResp, err := client.PolicyGet(ctx, connect.NewRequest(&limitsv1.PolicyGetRequest{Id: id}))
	if err != nil {
		return fmt.Errorf("PolicyGet: %w", err)
	}

	p := getResp.Msg.GetData()
	if p == nil {
		return fmt.Errorf("policy %q not found", id)
	}
	p.Mode = mode

	saveResp, err := client.PolicySave(ctx, connect.NewRequest(&limitsv1.PolicySaveRequest{
		Data: p,
	}))
	if err != nil {
		return fmt.Errorf("PolicySave: %w", err)
	}

	saved := saveResp.Msg.GetData()
	fmt.Fprintf(
		os.Stdout,
		"policy %s mode set to %s (version %d)\n",
		saved.GetId(),
		saved.GetMode().String(),
		saved.GetVersion(),
	)
	return nil
}
