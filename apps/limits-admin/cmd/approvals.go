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
	"errors"
	"fmt"
	"os"

	limitsv1 "buf.build/gen/go/antinvestor/limits/protocolbuffers/go/limits/v1"
	"connectrpc.com/connect"
	"github.com/spf13/cobra"
	"google.golang.org/protobuf/encoding/protojson"
)

func approvalsCmd() *cobra.Command {
	cmd := &cobra.Command{
		Use:   "approvals",
		Short: "Approve or reject pending approval requests",
	}

	cmd.AddCommand(approvalsApproveCmd())
	cmd.AddCommand(approvalsRejectCmd())

	return cmd
}

func approvalsApproveCmd() *cobra.Command {
	var flagReason string

	cmd := &cobra.Command{
		Use:   "approve <approval-request-id>",
		Short: "Approve a pending approval request",
		Args:  cobra.ExactArgs(1),
		RunE: func(cmd *cobra.Command, args []string) error {
			if flagReason == "" {
				return errors.New("--reason is required")
			}
			return decide(cmd.Context(), args[0], "approve", flagReason)
		},
	}

	cmd.Flags().StringVar(&flagReason, "reason", "", "Reason for the approval decision (required)")

	return cmd
}

func approvalsRejectCmd() *cobra.Command {
	var flagReason string

	cmd := &cobra.Command{
		Use:   "reject <approval-request-id>",
		Short: "Reject a pending approval request",
		Args:  cobra.ExactArgs(1),
		RunE: func(cmd *cobra.Command, args []string) error {
			if flagReason == "" {
				return errors.New("--reason is required")
			}
			return decide(cmd.Context(), args[0], "reject", flagReason)
		},
	}

	cmd.Flags().StringVar(&flagReason, "reason", "", "Reason for the rejection decision (required)")

	return cmd
}

// decide calls ApprovalRequestDecide with the given decision string ("approve" | "reject").
func decide(ctx context.Context, id, decision, note string) error {
	client, err := newAdminClient(ctx)
	if err != nil {
		return fmt.Errorf("build client: %w", err)
	}
	resp, err := client.ApprovalRequestDecide(
		ctx,
		connect.NewRequest(&limitsv1.ApprovalRequestDecideRequest{
			Id:       id,
			Decision: decision,
			Note:     note,
		}),
	)
	if err != nil {
		return fmt.Errorf("ApprovalRequestDecide: %w", err)
	}

	item := resp.Msg.GetData()
	if flagJSON {
		out, marshalErr := protojson.MarshalOptions{Indent: "  "}.Marshal(item)
		if marshalErr != nil {
			return marshalErr
		}
		fmt.Fprintln(os.Stdout, string(out))
		return nil
	}

	fmt.Fprintf(os.Stdout, "decision recorded: %s → %s (status: %s)\n",
		item.GetId(), decision, item.GetStatus().String())
	return nil
}
