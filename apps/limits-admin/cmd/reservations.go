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
	"os/signal"
	"syscall"
	"text/tabwriter"
	"time"

	limitsv1 "buf.build/gen/go/antinvestor/limits/protocolbuffers/go/limits/v1"
	"connectrpc.com/connect"
	"github.com/spf13/cobra"
	"google.golang.org/protobuf/encoding/protojson"
)

func reservationsCmd() *cobra.Command {
	cmd := &cobra.Command{
		Use:   "reservations",
		Short: "Inspect approval request reservations",
	}

	cmd.AddCommand(reservationsListCmd())
	cmd.AddCommand(reservationsShowCmd())

	return cmd
}

// watchInterval is how often --watch re-renders the reservation list.
const watchInterval = 5 * time.Second

func reservationsListCmd() *cobra.Command {
	var (
		flagStatus string
		flagWatch  bool
	)

	cmd := &cobra.Command{
		Use:   "list",
		Short: "List approval requests",
		RunE: func(cmd *cobra.Command, _ []string) error {
			status := limitsv1.ApprovalStatus_APPROVAL_STATUS_PENDING
			if flagStatus != "" {
				v, ok := limitsv1.ApprovalStatus_value[flagStatus]
				if !ok {
					return fmt.Errorf(
						"unknown status %q; valid values: APPROVAL_STATUS_PENDING, APPROVAL_STATUS_APPROVED, APPROVAL_STATUS_REJECTED, APPROVAL_STATUS_EXPIRED",
						flagStatus,
					)
				}
				status = limitsv1.ApprovalStatus(v)
			}

			if flagWatch {
				return watchReservations(cmd.Context(), status)
			}
			return listReservationsOnce(cmd.Context(), status)
		},
	}

	cmd.Flags().StringVar(&flagStatus, "status", "APPROVAL_STATUS_PENDING", "Filter by approval status")
	cmd.Flags().BoolVar(&flagWatch, "watch", false, "Re-render every 5s; exit with Ctrl-C")

	return cmd
}

func listReservationsOnce(ctx context.Context, status limitsv1.ApprovalStatus) error {
	client, err := newAdminClient(ctx)
	if err != nil {
		return fmt.Errorf("build client: %w", err)
	}
	req := &limitsv1.ApprovalRequestListRequest{
		Status: status,
	}

	stream, err := client.ApprovalRequestList(ctx, connect.NewRequest(req))
	if err != nil {
		return fmt.Errorf("ApprovalRequestList: %w", err)
	}

	var items []*limitsv1.ApprovalRequestObject
	for stream.Receive() {
		items = append(items, stream.Msg().GetData()...)
	}
	if streamErr := stream.Err(); streamErr != nil {
		return fmt.Errorf("stream error: %w", streamErr)
	}

	return renderReservations(items)
}

func renderReservations(items []*limitsv1.ApprovalRequestObject) error {
	if flagJSON {
		mo := protojson.MarshalOptions{Indent: "  "}
		for _, item := range items {
			out, err := mo.Marshal(item)
			if err != nil {
				return err
			}
			fmt.Fprintln(os.Stdout, string(out))
		}
		return nil
	}

	w := tabwriter.NewWriter(os.Stdout, 0, 0, tabPadding, ' ', 0)
	fmt.Fprintln(w, "ID\tRESERVATION_ID\tACTION\tSTATUS\tSUBMITTED_AT\tEXPIRES_AT")
	for _, item := range items {
		submittedAt := ""
		if ts := item.GetSubmittedAt(); ts != nil {
			submittedAt = ts.AsTime().UTC().Format(time.RFC3339)
		}
		expiresAt := ""
		if ts := item.GetExpiresAt(); ts != nil {
			expiresAt = ts.AsTime().UTC().Format(time.RFC3339)
		}
		fmt.Fprintf(w, "%s\t%s\t%s\t%s\t%s\t%s\n",
			item.GetId(),
			item.GetReservationId(),
			item.GetAction().String(),
			item.GetStatus().String(),
			submittedAt,
			expiresAt,
		)
	}
	return w.Flush()
}

func watchReservations(parentCtx context.Context, status limitsv1.ApprovalStatus) error {
	ctx, stop := signal.NotifyContext(parentCtx, syscall.SIGINT, syscall.SIGTERM)
	defer stop()

	ticker := time.NewTicker(watchInterval)
	defer ticker.Stop()

	// Run immediately, then on each tick.
	if err := listReservationsOnce(ctx, status); err != nil {
		return err
	}

	for {
		select {
		case <-ctx.Done():
			return nil
		case <-ticker.C:
			// Clear screen by printing ANSI escape.
			fmt.Fprint(os.Stdout, "\033[2J\033[H")
			if err := listReservationsOnce(ctx, status); err != nil {
				fmt.Fprintf(os.Stderr, "error: %v\n", err)
			}
		}
	}
}

func reservationsShowCmd() *cobra.Command {
	return &cobra.Command{
		Use:   "show <id>",
		Short: "Show a single approval request",
		Args:  cobra.ExactArgs(1),
		RunE: func(cmd *cobra.Command, args []string) error {
			client, err := newAdminClient(cmd.Context())
			if err != nil {
				return fmt.Errorf("build client: %w", err)
			}
			resp, err := client.ApprovalRequestGet(
				cmd.Context(),
				connect.NewRequest(&limitsv1.ApprovalRequestGetRequest{
					Id: args[0],
				}),
			)
			if err != nil {
				return fmt.Errorf("ApprovalRequestGet: %w", err)
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

			w := tabwriter.NewWriter(os.Stdout, 0, 0, tabPadding, ' ', 0)
			fmt.Fprintf(w, "ID:\t%s\n", item.GetId())
			fmt.Fprintf(w, "ReservationID:\t%s\n", item.GetReservationId())
			fmt.Fprintf(w, "Action:\t%s\n", item.GetAction().String())
			fmt.Fprintf(w, "Status:\t%s\n", item.GetStatus().String())
			fmt.Fprintf(w, "MakerID:\t%s\n", item.GetMakerId())
			fmt.Fprintf(w, "TriggeringPolicyID:\t%s\n", item.GetTriggeringPolicyId())
			fmt.Fprintf(w, "RequiredRole:\t%s\n", item.GetRequiredRole())
			fmt.Fprintf(w, "RequiredCount:\t%d\n", item.GetRequiredCount())
			if ts := item.GetSubmittedAt(); ts != nil {
				fmt.Fprintf(w, "SubmittedAt:\t%s\n", ts.AsTime().UTC().Format(time.RFC3339))
			}
			if ts := item.GetExpiresAt(); ts != nil {
				fmt.Fprintf(w, "ExpiresAt:\t%s\n", ts.AsTime().UTC().Format(time.RFC3339))
			}
			for i, d := range item.GetDecisions() {
				fmt.Fprintf(w, "Decision[%d]:\t%s by %s (%s)\n",
					i, d.GetDecision(), d.GetApproverId(), d.GetNote())
			}
			return w.Flush()
		},
	}
}
