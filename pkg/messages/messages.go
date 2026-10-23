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

// Package messages declares every notification the fintech services send,
// once, in code. Each service's setup job registers the catalogue with the
// notification service through notification.RegisterTemplateSync, and the
// runtime sends by template name with a payload. Bodies are Go
// text/template; the short form is the SMS body and the long form the email
// body. Amounts arrive pre-formatted in the payload (major units with the
// currency's ISO-4217 decimals) so a template never does arithmetic.
package messages

import "github.com/antinvestor/common/notification"

// Owner is the template namespace segment for every fintech service.
const Owner = "fintech"

// Loan lifecycle messages, sent to the borrower unless the name says otherwise.
const (
	LoanApplicationSubmitted = "template.fintech.loan.application_submitted"
	LoanApplicationApproved  = "template.fintech.loan.application_approved"
	LoanApplicationRejected  = "template.fintech.loan.application_rejected"
	LoanApplicationCancelled = "template.fintech.loan.application_cancelled"
	LoanDisbursed            = "template.fintech.loan.disbursed"
	LoanRepaymentReceived    = "template.fintech.loan.repayment_received"
	LoanPaidOff              = "template.fintech.loan.paid_off"
	LoanPaymentDue           = "template.fintech.loan.payment_due"
	LoanPaymentOverdue       = "template.fintech.loan.payment_overdue"
	LoanDelinquent           = "template.fintech.loan.delinquent"
	LoanPenaltyApplied       = "template.fintech.loan.penalty_applied"
	LoanPenaltyWaived        = "template.fintech.loan.penalty_waived"
	LoanRestructured         = "template.fintech.loan.restructured"
	LoanWrittenOff           = "template.fintech.loan.written_off"
	LoanCollectionRequested  = "template.fintech.loan.collection_requested"

	// Field-agent facing.
	AgentClientDelinquent    = "template.fintech.agent.client_delinquent"
	AgentDisbursementFailed  = "template.fintech.agent.disbursement_failed"
	AgentCollectionRecorded  = "template.fintech.agent.collection_recorded"
	AgentApplicationDecision = "template.fintech.agent.application_decision"
)

// Client onboarding and KYC messages.
const (
	ClientOnboarded          = "template.fintech.client.onboarded"
	ClientKYCVerified        = "template.fintech.client.kyc_verified"
	ClientKYCRejected        = "template.fintech.client.kyc_rejected"
	ClientKYCInfoRequested   = "template.fintech.client.kyc_info_requested"
	WorkforceMemberOnboarded = "template.fintech.workforce.member_onboarded"
)

// Approval case messages, sent to staff holding the relevant role and to the
// requester. The names predate this package and are kept so existing
// deployments keep resolving.
const (
	CaseVerificationRequired = "template.fintech.case.verification_required"
	CaseApprovalRequired     = "template.fintech.case.approval_required"
	CaseApproved             = "template.fintech.case.approved"
	CaseRejected             = "template.fintech.case.rejected"
)

// Payload keys shared by the templates.
const (
	VarClientName   = "client_name"
	VarAgentName    = "agent_name"
	VarLenderName   = "lender_name"
	VarLoanRef      = "loan_ref"
	VarAmount       = "amount"
	VarCurrency     = "currency"
	VarBalance      = "balance"
	VarDueDate      = "due_date"
	VarDaysOverdue  = "days_overdue"
	VarTermDays     = "term_days"
	VarReason       = "reason"
	VarChannel      = "channel"
	VarReference    = "reference"
	VarFieldLabel   = "field_label"
	VarCaseID       = "case_id"
	VarCaseType     = "case_type_label"
	VarCaseStatus   = "case_status_label"
	VarSubjectType  = "subject_type"
	VarSubjectID    = "subject_id"
	VarSummary      = "summary"
	VarRequestedBy  = "requested_by"
	VarRequested    = "requested_value"
	VarComment      = "comment"
	VarMemberName   = "member_name"
	VarOrganization = "organization_name"
)

//nolint:gochecknoglobals // template registry is declared once at package init
var registry = notification.NewRegistry(Owner)

//nolint:gochecknoinits // registers the immutable template catalogue
func init() {
	registry.MustAdd(loanOriginationTemplates()...)
	registry.MustAdd(loanServicingTemplates()...)
	registry.MustAdd(loanArrearsTemplates()...)
	registry.MustAdd(agentTemplates()...)
	registry.MustAdd(clientTemplates()...)
	registry.MustAdd(caseTemplates()...)
}

// Registry returns the template catalogue for setup-time registration.
func Registry() *notification.Registry { return registry }

func loanOriginationTemplates() []notification.Template {
	return []notification.Template{
		notification.New(
			LoanApplicationSubmitted,
			"Loan application {{.loan_ref}} received",
			"{{.lender_name}}: your loan application {{.loan_ref}} for {{.currency}} {{.amount}} has been received and is under review.",
			"Dear {{.client_name}},\n\nYour loan application {{.loan_ref}} for {{.currency}} {{.amount}} "+
				"over {{.term_days}} days has been received and is under review. We will let you know the decision.\n",
			VarLenderName,
			VarClientName,
			VarLoanRef,
			VarAmount,
			VarCurrency,
			VarTermDays,
		),
		notification.New(
			LoanApplicationApproved,
			"Loan application {{.loan_ref}} approved",
			"{{.lender_name}}: your loan {{.loan_ref}} for {{.currency}} {{.amount}} over {{.term_days}} days is approved. Disbursement follows shortly.",
			"Dear {{.client_name}},\n\nYour loan application {{.loan_ref}} has been approved for {{.currency}} {{.amount}} "+
				"over {{.term_days}} days. Disbursement will follow shortly.\n",
			VarLenderName,
			VarClientName,
			VarLoanRef,
			VarAmount,
			VarCurrency,
			VarTermDays,
		),
		notification.New(LoanApplicationRejected,
			"Loan application {{.loan_ref}} not approved",
			"{{.lender_name}}: your loan application {{.loan_ref}} was not approved. {{.reason}}",
			"Dear {{.client_name}},\n\nYour loan application {{.loan_ref}} was not approved.\n\nReason: {{.reason}}\n",
			VarLenderName, VarClientName, VarLoanRef, VarReason),
		notification.New(
			LoanApplicationCancelled,
			"Loan application {{.loan_ref}} cancelled",
			"{{.lender_name}}: your loan application {{.loan_ref}} has been cancelled. {{.reason}}",
			"Dear {{.client_name}},\n\nYour loan application {{.loan_ref}} has been cancelled.\n\nReason: {{.reason}}\n",
			VarLenderName,
			VarClientName,
			VarLoanRef,
			VarReason,
		),
		notification.New(
			LoanDisbursed,
			"Loan {{.loan_ref}} disbursed",
			"{{.lender_name}}: {{.currency}} {{.amount}} for loan {{.loan_ref}} has been sent via {{.channel}}. First payment is due {{.due_date}}.",
			"Dear {{.client_name}},\n\n{{.currency}} {{.amount}} for loan {{.loan_ref}} has been disbursed via {{.channel}}.\n\n"+
				"Your first repayment is due on {{.due_date}}.\n",
			VarLenderName,
			VarClientName,
			VarLoanRef,
			VarAmount,
			VarCurrency,
			VarChannel,
			VarDueDate,
		),
	}
}

func loanServicingTemplates() []notification.Template {
	return []notification.Template{
		notification.New(
			LoanRepaymentReceived,
			"Payment received for loan {{.loan_ref}}",
			"{{.lender_name}}: payment of {{.currency}} {{.amount}} received for loan {{.loan_ref}} ({{.channel}}). Balance: {{.currency}} {{.balance}}.",
			"Dear {{.client_name}},\n\nWe received {{.currency}} {{.amount}} for loan {{.loan_ref}} via {{.channel}}"+
				" (ref {{.reference}}).\n\nOutstanding balance: {{.currency}} {{.balance}}.\n",
			VarLenderName,
			VarClientName,
			VarLoanRef,
			VarAmount,
			VarCurrency,
			VarBalance,
			VarChannel,
			VarReference,
		),
		notification.New(
			LoanPaidOff,
			"Loan {{.loan_ref}} fully repaid",
			"{{.lender_name}}: loan {{.loan_ref}} is fully repaid. Thank you.",
			"Dear {{.client_name}},\n\nLoan {{.loan_ref}} is now fully repaid. Thank you for banking with {{.lender_name}}.\n",
			VarLenderName,
			VarClientName,
			VarLoanRef,
		),
		notification.New(
			LoanPaymentDue,
			"Payment due {{.due_date}} for loan {{.loan_ref}}",
			"{{.lender_name}}: {{.currency}} {{.amount}} is due on {{.due_date}} for loan {{.loan_ref}}.",
			"Dear {{.client_name}},\n\nA repayment of {{.currency}} {{.amount}} for loan {{.loan_ref}} is due on {{.due_date}}.\n",
			VarLenderName,
			VarClientName,
			VarLoanRef,
			VarAmount,
			VarCurrency,
			VarDueDate,
		),
		notification.New(
			LoanPaymentOverdue,
			"Overdue payment on loan {{.loan_ref}}",
			"{{.lender_name}}: {{.currency}} {{.amount}} on loan {{.loan_ref}} is {{.days_overdue}} days overdue. Please pay to avoid penalties.",
			"Dear {{.client_name}},\n\nA repayment of {{.currency}} {{.amount}} on loan {{.loan_ref}} was due on {{.due_date}} "+
				"and is now {{.days_overdue}} days overdue. Please pay as soon as possible to avoid penalties.\n",
			VarLenderName,
			VarClientName,
			VarLoanRef,
			VarAmount,
			VarCurrency,
			VarDueDate,
			VarDaysOverdue,
		),
		notification.New(
			LoanDelinquent,
			"Loan {{.loan_ref}} is in arrears",
			"{{.lender_name}}: loan {{.loan_ref}} is {{.days_overdue}} days in arrears; {{.currency}} {{.balance}} outstanding. Contact us to arrange payment.",
			"Dear {{.client_name}},\n\nLoan {{.loan_ref}} is {{.days_overdue}} days in arrears with {{.currency}} {{.balance}} outstanding. "+
				"Please contact us or your field officer to arrange payment.\n",
			VarLenderName,
			VarClientName,
			VarLoanRef,
			VarBalance,
			VarCurrency,
			VarDaysOverdue,
		),
	}
}

func loanArrearsTemplates() []notification.Template {
	return []notification.Template{
		notification.New(
			LoanPenaltyApplied,
			"Penalty applied to loan {{.loan_ref}}",
			"{{.lender_name}}: a penalty of {{.currency}} {{.amount}} was applied to loan {{.loan_ref}}. {{.reason}}",
			"Dear {{.client_name}},\n\nA penalty of {{.currency}} {{.amount}} has been applied to loan {{.loan_ref}}.\n\nReason: {{.reason}}\n",
			VarLenderName,
			VarClientName,
			VarLoanRef,
			VarAmount,
			VarCurrency,
			VarReason,
		),
		notification.New(LoanPenaltyWaived,
			"Penalty waived on loan {{.loan_ref}}",
			"{{.lender_name}}: a penalty of {{.currency}} {{.amount}} on loan {{.loan_ref}} has been waived.",
			"Dear {{.client_name}},\n\nA penalty of {{.currency}} {{.amount}} on loan {{.loan_ref}} has been waived.\n",
			VarLenderName, VarClientName, VarLoanRef, VarAmount, VarCurrency),
		notification.New(
			LoanRestructured,
			"Loan {{.loan_ref}} restructured",
			"{{.lender_name}}: loan {{.loan_ref}} has been restructured. New balance {{.currency}} {{.balance}}; next payment due {{.due_date}}.",
			"Dear {{.client_name}},\n\nLoan {{.loan_ref}} has been restructured. Outstanding balance: {{.currency}} {{.balance}}. "+
				"Your next repayment is due on {{.due_date}}.\n",
			VarLenderName,
			VarClientName,
			VarLoanRef,
			VarBalance,
			VarCurrency,
			VarDueDate,
		),
		notification.New(
			LoanWrittenOff,
			"Loan {{.loan_ref}} closed",
			"{{.lender_name}}: loan {{.loan_ref}} has been closed with {{.currency}} {{.balance}} written off. Contact us for any queries.",
			"Dear {{.client_name}},\n\nLoan {{.loan_ref}} has been closed and {{.currency}} {{.balance}} written off. "+
				"Please contact us for any queries.\n",
			VarLenderName,
			VarClientName,
			VarLoanRef,
			VarBalance,
			VarCurrency,
		),
		notification.New(
			LoanCollectionRequested,
			"Payment request for loan {{.loan_ref}}",
			"{{.lender_name}}: please pay {{.currency}} {{.amount}} towards loan {{.loan_ref}}. Reference {{.reference}}.",
			"Dear {{.client_name}},\n\nPlease pay {{.currency}} {{.amount}} towards loan {{.loan_ref}} using reference {{.reference}}.\n",
			VarLenderName,
			VarClientName,
			VarLoanRef,
			VarAmount,
			VarCurrency,
			VarReference,
		),
	}
}

func agentTemplates() []notification.Template {
	return []notification.Template{
		notification.New(
			AgentClientDelinquent,
			"Client {{.client_name}} in arrears",
			"{{.lender_name}}: your client {{.client_name}} (loan {{.loan_ref}}) is {{.days_overdue}} days in arrears, {{.currency}} {{.balance}} outstanding.",
			"Hello {{.agent_name}},\n\nYour client {{.client_name}} is {{.days_overdue}} days in arrears on loan {{.loan_ref}} "+
				"with {{.currency}} {{.balance}} outstanding. Please follow up.\n",
			VarLenderName,
			VarAgentName,
			VarClientName,
			VarLoanRef,
			VarBalance,
			VarCurrency,
			VarDaysOverdue,
		),
		notification.New(
			AgentDisbursementFailed,
			"Disbursement failed for loan {{.loan_ref}}",
			"{{.lender_name}}: disbursement of {{.currency}} {{.amount}} for {{.client_name}} (loan {{.loan_ref}}) failed: {{.reason}}",
			"Hello {{.agent_name}},\n\nThe disbursement of {{.currency}} {{.amount}} for {{.client_name}} on loan {{.loan_ref}} "+
				"failed.\n\nReason: {{.reason}}\n",
			VarLenderName,
			VarAgentName,
			VarClientName,
			VarLoanRef,
			VarAmount,
			VarCurrency,
			VarReason,
		),
		notification.New(
			AgentCollectionRecorded,
			"Collection recorded for loan {{.loan_ref}}",
			"{{.lender_name}}: you recorded {{.currency}} {{.amount}} from {{.client_name}} (loan {{.loan_ref}}) via {{.channel}}, ref {{.reference}}.",
			"Hello {{.agent_name}},\n\nYou recorded a collection of {{.currency}} {{.amount}} from {{.client_name}} on loan {{.loan_ref}} "+
				"via {{.channel}} (ref {{.reference}}). Cash collected in the field must be remitted by the end of the day.\n",
			VarLenderName,
			VarAgentName,
			VarClientName,
			VarLoanRef,
			VarAmount,
			VarCurrency,
			VarChannel,
			VarReference,
		),
		notification.New(
			AgentApplicationDecision,
			"Application {{.loan_ref}} {{.case_status_label}}",
			"{{.lender_name}}: application {{.loan_ref}} for {{.client_name}} is {{.case_status_label}}. {{.reason}}",
			"Hello {{.agent_name}},\n\nThe loan application {{.loan_ref}} you submitted for {{.client_name}} is {{.case_status_label}}.\n\n{{.reason}}\n",
			VarLenderName,
			VarAgentName,
			VarClientName,
			VarLoanRef,
			VarCaseStatus,
			VarReason,
		),
	}
}

func clientTemplates() []notification.Template {
	return []notification.Template{
		notification.New(
			ClientOnboarded,
			"Welcome to {{.lender_name}}",
			"Welcome to {{.lender_name}}, {{.client_name}}. Your field officer {{.agent_name}} has registered you. Reply STOP to opt out.",
			"Dear {{.client_name}},\n\nWelcome to {{.lender_name}}. Your field officer {{.agent_name}} has registered you as a client. "+
				"We will contact you about the next steps.\n",
			VarLenderName,
			VarClientName,
			VarAgentName,
		),
		notification.New(ClientKYCVerified,
			"Your {{.field_label}} has been verified",
			"{{.lender_name}}: your {{.field_label}} has been verified.",
			"Dear {{.client_name}},\n\nYour {{.field_label}} has been verified. Thank you.\n",
			VarLenderName, VarClientName, VarFieldLabel),
		notification.New(
			ClientKYCRejected,
			"Your {{.field_label}} could not be verified",
			"{{.lender_name}}: your {{.field_label}} could not be verified. {{.reason}} Please contact your field officer.",
			"Dear {{.client_name}},\n\nYour {{.field_label}} could not be verified.\n\nReason: {{.reason}}\n\n"+
				"Please contact your field officer to resubmit.\n",
			VarLenderName,
			VarClientName,
			VarFieldLabel,
			VarReason,
		),
		notification.New(ClientKYCInfoRequested,
			"More information needed for your {{.field_label}}",
			"{{.lender_name}}: we need more information about your {{.field_label}}. {{.reason}}",
			"Dear {{.client_name}},\n\nWe need more information about your {{.field_label}}.\n\n{{.reason}}\n",
			VarLenderName, VarClientName, VarFieldLabel, VarReason),
		notification.New(
			WorkforceMemberOnboarded,
			"Welcome to {{.organization_name}}",
			"{{.organization_name}}: {{.member_name}}, your staff account is ready. Sign in to accept the terms and start work.",
			"Hello {{.member_name}},\n\nYour staff account at {{.organization_name}} is ready. Sign in to accept the terms "+
				"of service and start working with your clients.\n",
			VarOrganization,
			VarMemberName,
		),
	}
}

func caseTemplates() []notification.Template {
	return []notification.Template{
		notification.New(
			CaseVerificationRequired,
			"Verification required: {{.case_type_label}}",
			"{{.case_type_label}} case {{.case_id}} needs verification: {{.summary}}",
			"A {{.case_type_label}} case ({{.case_id}}) needs your verification.\n\nSubject: {{.subject_type}} {{.subject_id}}\n"+
				"Requested by: {{.requested_by}}\nRequested value: {{.requested_value}}\n\n{{.summary}}\n",
			VarCaseID,
			VarCaseType,
			VarCaseStatus,
			VarSubjectType,
			VarSubjectID,
			VarSummary,
			VarRequestedBy,
			VarRequested,
		),
		notification.New(
			CaseApprovalRequired,
			"Approval required: {{.case_type_label}}",
			"{{.case_type_label}} case {{.case_id}} needs approval: {{.summary}}",
			"A {{.case_type_label}} case ({{.case_id}}) needs your approval.\n\nSubject: {{.subject_type}} {{.subject_id}}\n"+
				"Requested by: {{.requested_by}}\nRequested value: {{.requested_value}}\n\n{{.summary}}\n",
			VarCaseID,
			VarCaseType,
			VarCaseStatus,
			VarSubjectType,
			VarSubjectID,
			VarSummary,
			VarRequestedBy,
			VarRequested,
		),
		notification.New(CaseApproved,
			"{{.case_type_label}} approved",
			"Your {{.case_type_label}} request {{.case_id}} was approved. {{.comment}}",
			"Your {{.case_type_label}} request ({{.case_id}}) was approved.\n\n{{.comment}}\n",
			VarCaseID, VarCaseType, VarCaseStatus, VarSummary, VarComment),
		notification.New(CaseRejected,
			"{{.case_type_label}} rejected",
			"Your {{.case_type_label}} request {{.case_id}} was rejected. {{.comment}}",
			"Your {{.case_type_label}} request ({{.case_id}}) was rejected.\n\n{{.comment}}\n",
			VarCaseID, VarCaseType, VarCaseStatus, VarSummary, VarComment),
	}
}
