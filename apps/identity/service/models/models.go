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

package models

import (
	"context"
	"time"

	commonv1 "buf.build/gen/go/antinvestor/common/protocolbuffers/go/common/v1"
	fieldv1 "buf.build/gen/go/antinvestor/field/protocolbuffers/go/field/v1"
	identityv1 "buf.build/gen/go/antinvestor/identity/protocolbuffers/go/identity/v1"
	"github.com/pitabwire/frame/data"
	"github.com/pitabwire/util/decimalx"
	moneyx "github.com/pitabwire/util/moneyx"
)

const (
	// decimalPrecision is the precision used by the String<->MinorUnits helpers
	// below. Money conversions go via moneyx and honour ISO 4217 per currency.
	decimalPrecision = 2
	// extraPropertiesCount is the number of extra properties added when converting to API.
	extraPropertiesCount = 3
)

// MinorUnitsToString converts an int64 minor-unit amount (e.g. cents) to a
// decimal string with two fractional digits. 123456 -> "1234.56".
func MinorUnitsToString(v int64) string {
	return decimalx.FromMinorUnits(v, decimalPrecision).String()
}

// StringToMinorUnits parses a decimal string (e.g. "1234.56") into int64 minor
// units. Uses string splitting to avoid float precision issues. Returns 0 on
// parse error.
func StringToMinorUnits(s string) int64 {
	d, err := decimalx.NewFromString(s)
	if err != nil {
		return 0
	}
	return d.ToMinorUnits(decimalPrecision)
}

// MinorUnitsToMoney converts minor units and a currency code to a *commonv1.Money.
// Precision follows ISO 4217 via moneyx.Decimals (JPY=0, KWD/BHD/OMR=3, else=2).
func MinorUnitsToMoney(v int64, currencyCode string) *commonv1.Money {
	return moneyx.FromMinorUnitsByCurrency(currencyCode, v)
}

// MoneyToMinorUnits converts a *commonv1.Money to minor units and currency code.
// Precision follows ISO 4217 via moneyx.Decimals.
func MoneyToMinorUnits(m *commonv1.Money) (int64, string) {
	if m == nil {
		return 0, ""
	}
	cc := m.GetCurrencyCode()
	return moneyx.ToSmallestUnit(m, moneyx.Decimals(cc)), cc
}

// Organization represents a top-level lending institution mapped to a partition.
type Organization struct {
	data.BaseModel
	Name             string `gorm:"type:varchar(255)"`
	Code             string `gorm:"type:varchar(50);uniqueIndex:uq_organization_code"`
	ProfileID        string `gorm:"type:varchar(50)"`
	ClientID         string `gorm:"type:varchar(50)"` // OAuth client ID for partition-scoped login
	GeoID            string `gorm:"type:varchar(50)"`
	ParentID         string `gorm:"type:varchar(50);index"`
	Domain           string `gorm:"type:varchar(255)"` // Primary web domain (e.g. "stawi.org")
	HasChildren      bool   `gorm:"default:false"`
	OrganizationType int32  `gorm:"default:0"` // maps to identityv1.OrganizationType enum
	State            int32
	Properties       data.JSONMap
}

func (m *Organization) TableName() string { return "organizations" }

func (m *Organization) ToAPI() *identityv1.OrganizationObject {
	return &identityv1.OrganizationObject{
		Id:               m.GetID(),
		PartitionId:      m.PartitionID,
		Name:             m.Name,
		Code:             m.Code,
		ProfileId:        m.ProfileID,
		State:            commonv1.STATE(m.State),
		OrganizationType: identityv1.OrganizationType(m.OrganizationType),
		Properties:       m.Properties.ToProtoStruct(),
		ClientId:         m.ClientID,
		GeoId:            m.GeoID,
		ParentId:         m.ParentID,
		HasChildren:      m.HasChildren,
		Domain:           m.Domain,
	}
}

func OrganizationFromAPI(ctx context.Context, obj *identityv1.OrganizationObject) *Organization {
	if obj == nil {
		return nil
	}

	model := &Organization{
		Name:             obj.GetName(),
		Code:             obj.GetCode(),
		ProfileID:        obj.GetProfileId(),
		ClientID:         obj.GetClientId(),
		GeoID:            obj.GetGeoId(),
		ParentID:         obj.GetParentId(),
		Domain:           obj.GetDomain(),
		OrganizationType: int32(obj.GetOrganizationType()),
		State:            int32(obj.GetState()),
	}

	if obj.GetProperties() != nil {
		model.Properties = (&data.JSONMap{}).FromProtoStruct(obj.GetProperties())
	}

	model.PartitionID = obj.GetPartitionId()
	model.GenID(ctx)
	if model.ValidXID(obj.GetId()) {
		model.ID = obj.GetId()
	}

	return model
}

// Branch is the legacy leaf-unit compatibility model backed by the org_units table.
// Canonical hierarchy management should use OrgUnitObject with UnitType set explicitly.
type Branch struct {
	data.BaseModel
	OrganizationID string `gorm:"type:varchar(50);index:idx_branch_organization"`
	ParentID       string `gorm:"type:varchar(50);index:idx_org_unit_parent"`
	Name           string `gorm:"type:varchar(255)"`
	Code           string `gorm:"type:varchar(50);uniqueIndex:uq_branch_code"`
	ProfileID      string `gorm:"type:varchar(50)"` // Profile for contacts, addresses, avatar
	GeoID          string `gorm:"type:varchar(50)"`
	UnitType       int32  `gorm:"column:unit_type;index:idx_org_unit_type"`
	ClientID       string `gorm:"type:varchar(50)"` // OAuth client ID for partition-scoped login
	State          int32
	Properties     data.JSONMap
}

func (m *Branch) TableName() string { return "org_units" }

func (m *Branch) ToOrgUnitAPI(hasChildren bool) *identityv1.OrgUnitObject {
	return &identityv1.OrgUnitObject{
		Id:             m.GetID(),
		OrganizationId: m.OrganizationID,
		ParentId:       m.ParentID,
		PartitionId:    m.PartitionID,
		Name:           m.Name,
		Code:           m.Code,
		ProfileId:      m.ProfileID,
		GeoId:          m.GeoID,
		State:          commonv1.STATE(m.State),
		Type:           identityv1.OrgUnitType(m.UnitType),
		Properties:     m.Properties.ToProtoStruct(),
		ClientId:       m.ClientID,
		HasChildren:    hasChildren,
	}
}

func OrgUnitFromAPI(ctx context.Context, obj *identityv1.OrgUnitObject) *Branch {
	if obj == nil {
		return nil
	}

	model := &Branch{
		OrganizationID: obj.GetOrganizationId(),
		ParentID:       obj.GetParentId(),
		Name:           obj.GetName(),
		Code:           obj.GetCode(),
		ProfileID:      obj.GetProfileId(),
		GeoID:          obj.GetGeoId(),
		UnitType:       int32(obj.GetType()),
		ClientID:       obj.GetClientId(),
		State:          int32(obj.GetState()),
	}

	if obj.GetProperties() != nil {
		model.Properties = (&data.JSONMap{}).FromProtoStruct(obj.GetProperties())
	}

	model.PartitionID = obj.GetPartitionId()
	model.GenID(ctx)
	if model.ValidXID(obj.GetId()) {
		model.ID = obj.GetId()
	}

	return model
}

// Agent represents a field agent in the lending hierarchy.
// Agents belong to an organization and can be assigned to multiple branches via AgentBranch.
type Agent struct {
	data.BaseModel
	OrganizationID string `gorm:"type:varchar(50);index:idx_agent_organization;not null"`
	ParentAgentID  string `gorm:"type:varchar(50);index:idx_agent_parent"`
	ProfileID      string `gorm:"type:varchar(50)"`
	AgentType      int32
	Name           string `gorm:"type:varchar(255)"`
	GeoID          string `gorm:"type:varchar(50)"`
	Depth          int32
	State          int32
	Properties     data.JSONMap
}

func (m *Agent) TableName() string { return "agents" }

func (m *Agent) ToAPI() *fieldv1.AgentObject {
	return &fieldv1.AgentObject{
		Id:             m.GetID(),
		OrganizationId: m.OrganizationID,
		ParentAgentId:  m.ParentAgentID,
		ProfileId:      m.ProfileID,
		AgentType:      fieldv1.AgentType(m.AgentType),
		Name:           m.Name,
		GeoId:          m.GeoID,
		Depth:          m.Depth,
		State:          commonv1.STATE(m.State),
		Properties:     m.Properties.ToProtoStruct(),
	}
}

func AgentFromAPI(ctx context.Context, obj *fieldv1.AgentObject) *Agent {
	if obj == nil {
		return nil
	}

	model := &Agent{
		OrganizationID: obj.GetOrganizationId(),
		ParentAgentID:  obj.GetParentAgentId(),
		ProfileID:      obj.GetProfileId(),
		AgentType:      int32(obj.GetAgentType()),
		Name:           obj.GetName(),
		GeoID:          obj.GetGeoId(),
		Depth:          obj.GetDepth(),
		State:          int32(obj.GetState()),
	}

	if obj.GetProperties() != nil {
		model.Properties = (&data.JSONMap{}).FromProtoStruct(obj.GetProperties())
	}

	model.GenID(ctx)
	if model.ValidXID(obj.GetId()) {
		model.ID = obj.GetId()
	}

	return model
}

// AgentBranch links an agent to a branch (many-to-many).
// Each assignment can carry its own state and properties (e.g. commission structure).
type AgentBranch struct {
	data.BaseModel
	AgentID    string `gorm:"type:varchar(50);uniqueIndex:uq_agent_branch,priority:1;not null"`
	BranchID   string `gorm:"type:varchar(50);uniqueIndex:uq_agent_branch,priority:2;index:idx_ab_branch;not null"`
	State      int32
	Properties data.JSONMap
}

func (m *AgentBranch) TableName() string { return "agent_branches" }

func (m *AgentBranch) ToAPI() *fieldv1.AgentBranchObject {
	return &fieldv1.AgentBranchObject{
		Id:         m.GetID(),
		AgentId:    m.AgentID,
		BranchId:   m.BranchID,
		State:      commonv1.STATE(m.State),
		Properties: m.Properties.ToProtoStruct(),
	}
}

func AgentBranchFromAPI(ctx context.Context, obj *fieldv1.AgentBranchObject) *AgentBranch {
	if obj == nil {
		return nil
	}

	model := &AgentBranch{
		AgentID:  obj.GetAgentId(),
		BranchID: obj.GetBranchId(),
		State:    int32(obj.GetState()),
	}

	if obj.GetProperties() != nil {
		model.Properties = (&data.JSONMap{}).FromProtoStruct(obj.GetProperties())
	}

	model.GenID(ctx)
	if model.ValidXID(obj.GetId()) {
		model.ID = obj.GetId()
	}

	return model
}

// Client represents a loan recipient owned by a team.
// Client-to-member relationships are managed via client_relationships table.
// Clients exist independently of groups. Product-level code links clients to memberships where needed.
//
// Credit limits:
//   - SystemCreditLimit: hard maximum that evolves with client performance.
//     Can only be changed through a verified CreditLimitChangeRequest.
//   - AgentCreditLimit: set by the responsible agent, between 0 and SystemCreditLimit.
//     Controls what the agent is willing to issue to this client.
//   - Effective limit = min(SystemCreditLimit, AgentCreditLimit).
type Client struct {
	data.BaseModel
	AgentID           string `gorm:"column:agent_id;type:varchar(50);index:idx_client_agent"`
	OwningTeamID      string `gorm:"type:varchar(50);index:idx_client_owning_team;not null;default:''"`
	ProfileID         string `gorm:"type:varchar(50);uniqueIndex:uq_client_profile"`
	Name              string `gorm:"type:varchar(255)"`
	CurrencyCode      string `gorm:"type:varchar(3)"`
	SystemCreditLimit int64
	AgentCreditLimit  int64
	State             int32
	Properties        data.JSONMap
}

func (m *Client) TableName() string { return "clients" }

// EffectiveCreditLimit returns the lower of the two limits.
// If either limit is zero, the other applies. If both are zero, no credit.
func (m *Client) EffectiveCreditLimit() int64 {
	sys := m.SystemCreditLimit
	agent := m.AgentCreditLimit
	if sys <= 0 {
		return 0
	}
	if agent <= 0 {
		return 0
	}
	if agent < sys {
		return agent
	}
	return sys
}

func (m *Client) ToAPI() *fieldv1.ClientObject {
	// Copy properties so we don't mutate the model's map
	props := make(data.JSONMap, len(m.Properties)+extraPropertiesCount)
	for k, v := range m.Properties {
		props[k] = v
	}
	if phone, ok := props["phone"].(string); ok && phone != "" {
		if _, hasCanonical := props["phone_number"]; !hasCanonical {
			props["phone_number"] = phone
		}
		delete(props, "phone")
	}
	// Ensure credit limits are visible in properties for downstream consumers
	props["system_credit_limit"] = float64(m.SystemCreditLimit)
	props["agent_credit_limit"] = float64(m.AgentCreditLimit)
	props["currency_code"] = m.CurrencyCode

	return &fieldv1.ClientObject{
		Id:           m.GetID(),
		AgentId:      m.AgentID,
		ProfileId:    m.ProfileID,
		Name:         m.Name,
		State:        commonv1.STATE(m.State),
		Properties:   props.ToProtoStruct(),
		OwningTeamId: m.OwningTeamID,
	}
}

func ClientFromAPI(ctx context.Context, obj *fieldv1.ClientObject) *Client {
	if obj == nil {
		return nil
	}

	model := &Client{
		AgentID:      obj.GetAgentId(),
		OwningTeamID: obj.GetOwningTeamId(),
		ProfileID:    obj.GetProfileId(),
		Name:         obj.GetName(),
		State:        int32(obj.GetState()),
	}

	if obj.GetProperties() != nil {
		model.Properties = (&data.JSONMap{}).FromProtoStruct(obj.GetProperties())
	}
	if phone, ok := model.Properties["phone"].(string); ok && phone != "" {
		if _, hasCanonical := model.Properties["phone_number"]; !hasCanonical {
			model.Properties["phone_number"] = phone
		}
		delete(model.Properties, "phone")
	}

	model.GenID(ctx)
	if model.ValidXID(obj.GetId()) {
		model.ID = obj.GetId()
	}

	return model
}

// CreditLimitChangeRequest records a request to change the system credit limit.
// Changes to the hard limit must go through a verification and approval process.
type CreditLimitChangeRequest struct {
	data.BaseModel
	ClientID       string `gorm:"type:varchar(50);index:idx_clcr_client;not null"`
	CurrentLimit   int64  // minor units — limit at time of request
	RequestedLimit int64  // minor units — proposed new limit
	CurrencyCode   string `gorm:"type:varchar(3)"`
	Reason         string `gorm:"type:text"`
	RequestedBy    string `gorm:"type:varchar(50)"` // agent or system user who initiated
	ReviewedBy     string `gorm:"type:varchar(50)"` // who approved/rejected
	ReviewNotes    string `gorm:"type:text"`
	Status         int32  // 1=pending, 3=approved, 5=rejected
	Properties     data.JSONMap
}

func (m *CreditLimitChangeRequest) TableName() string { return "credit_limit_change_requests" }

// ApprovalCase captures a reusable verification and approval workflow for any
// pending business action whose end state must not be actualized immediately.
type ApprovalCase struct {
	data.BaseModel
	SubjectType string `gorm:"type:varchar(50);index:idx_approval_case_subject;not null"`
	SubjectID   string `gorm:"type:varchar(50);index:idx_approval_case_subject;not null"`
	CaseType    string `gorm:"type:varchar(100);index:idx_approval_case_type;not null"`
	Status      string `gorm:"type:varchar(50);index:idx_approval_case_status;not null"`
	Summary     string `gorm:"type:text"`
	RequestedBy string `gorm:"type:varchar(50);index:idx_approval_case_requested_by"`
	VerifiedBy  string `gorm:"type:varchar(50)"`
	ApprovedBy  string `gorm:"type:varchar(50)"`
	RejectedBy  string `gorm:"type:varchar(50)"`
	VerifiedAt  *time.Time
	ApprovedAt  *time.Time
	RejectedAt  *time.Time
	Comment     string `gorm:"type:text"`
	Payload     data.JSONMap
	Properties  data.JSONMap
}

func (m *ApprovalCase) TableName() string { return "approval_cases" }

// GroupType defines the type of customer group.
type GroupType int32

const (
	GroupTypeUnspecified  GroupType = 0
	GroupTypeProduct      GroupType = 1
	GroupTypeGrameen      GroupType = 2
	GroupTypeFunding      GroupType = 3
	GroupTypeTemporary    GroupType = 4
	GroupTypeMerryGoRound GroupType = 5
	GroupTypeVoluntary    GroupType = 6
)

// GroupState defines the lifecycle state of a group.
type GroupState int32

const (
	GroupStateJustCreated  GroupState = 1
	GroupStateCheckCreated GroupState = 2
	GroupStateActive       GroupState = 3
	GroupStateInactive     GroupState = 4
	GroupStateDeleted      GroupState = 5
	GroupStateShutdown     GroupState = 6
)

// MembershipRole defines the role of a member in a group.
type MembershipRole int32

const (
	MembershipRoleUnspecified MembershipRole = 0
	MembershipRoleMember      MembershipRole = 1
	MembershipRoleLeader      MembershipRole = 2
	MembershipRoleAgent       MembershipRole = 3
)

// MembershipType defines the type of membership.
type MembershipType int32

const (
	MembershipTypeUnspecified MembershipType = 0
	MembershipTypeRegistra    MembershipType = 1
	MembershipTypeAgent       MembershipType = 2
	MembershipTypeMember      MembershipType = 3
	MembershipTypeFunder      MembershipType = 4
)

// ClientGroup represents a collective entity (e.g. SACCO group) in the lending hierarchy.
type ClientGroup struct {
	data.BaseModel
	ProductID     string `gorm:"type:varchar(50);index:idx_group_product"`
	ParentID      string `gorm:"type:varchar(50);index:idx_group_parent"`
	AgentID       string `gorm:"type:varchar(50);index:idx_group_agent"`
	BranchID      string `gorm:"type:varchar(50);index:idx_group_branch"`
	ProfileID     string `gorm:"type:varchar(50)"`
	Name          string `gorm:"type:varchar(255)"`
	GroupType     int32
	CurrencyCode  string `gorm:"type:varchar(10)"`
	SavingAmount  int64
	TimeZone      string `gorm:"type:varchar(50)"`
	MinMembers    int32
	MaxMembers    int32
	DateActive    *time.Time
	DateChecked   *time.Time
	DateInspected *time.Time
	State         int32
	Properties    data.JSONMap
}

func (m *ClientGroup) TableName() string { return "client_groups" }

// SetVersion implements the versioned model interface for event upsert.
func (m *ClientGroup) SetVersion(v uint) { m.Version = v }

func (m *ClientGroup) ToAPI() *identityv1.ClientGroupObject {
	return &identityv1.ClientGroupObject{
		Id:           m.GetID(),
		ProductId:    m.ProductID,
		ParentId:     m.ParentID,
		AgentId:      m.AgentID,
		BranchId:     m.BranchID,
		ProfileId:    m.ProfileID,
		Name:         m.Name,
		GroupType:    m.GroupType,
		CurrencyCode: m.CurrencyCode,
		SavingAmount: m.SavingAmount,
		TimeZone:     m.TimeZone,
		MinMembers:   m.MinMembers,
		MaxMembers:   m.MaxMembers,
		State:        commonv1.STATE(m.State),
		Properties:   m.Properties.ToProtoStruct(),
	}
}

func ClientGroupFromAPI(ctx context.Context, obj *identityv1.ClientGroupObject) *ClientGroup {
	if obj == nil {
		return nil
	}

	model := &ClientGroup{
		ProductID:    obj.GetProductId(),
		ParentID:     obj.GetParentId(),
		AgentID:      obj.GetAgentId(),
		BranchID:     obj.GetBranchId(),
		ProfileID:    obj.GetProfileId(),
		Name:         obj.GetName(),
		GroupType:    obj.GetGroupType(),
		CurrencyCode: obj.GetCurrencyCode(),
		SavingAmount: obj.GetSavingAmount(),
		TimeZone:     obj.GetTimeZone(),
		MinMembers:   obj.GetMinMembers(),
		MaxMembers:   obj.GetMaxMembers(),
		State:        int32(obj.GetState()),
	}

	if obj.GetProperties() != nil {
		model.Properties = (&data.JSONMap{}).FromProtoStruct(obj.GetProperties())
	}

	model.GenID(ctx)
	if model.ValidXID(obj.GetId()) {
		model.ID = obj.GetId()
	}

	return model
}

// Membership tracks a profile's affiliation with a group.
type Membership struct {
	data.BaseModel
	GroupID         string `gorm:"type:varchar(50);index:idx_membership_group"`
	ProfileID       string `gorm:"type:varchar(50);index:idx_membership_profile"`
	Name            string `gorm:"type:varchar(255)"`
	ContactID       string `gorm:"type:varchar(50);index:idx_membership_contact"`
	Role            int32
	MembershipType  int32
	OrderNo         int32
	TimeZone        string `gorm:"type:varchar(50)"`
	PrevLoanReqDate *time.Time
	NextLoanReqDate *time.Time
	State           int32
	Properties      data.JSONMap
}

func (m *Membership) TableName() string { return "memberships" }

// SetVersion implements the versioned model interface for event upsert.
func (m *Membership) SetVersion(v uint) { m.Version = v }

func (m *Membership) ToAPI() *identityv1.MembershipObject {
	return &identityv1.MembershipObject{
		Id:             m.GetID(),
		GroupId:        m.GroupID,
		ProfileId:      m.ProfileID,
		Name:           m.Name,
		ContactId:      m.ContactID,
		Role:           m.Role,
		MembershipType: m.MembershipType,
		OrderNo:        m.OrderNo,
		State:          commonv1.STATE(m.State),
		Properties:     m.Properties.ToProtoStruct(),
	}
}

func MembershipFromAPI(ctx context.Context, obj *identityv1.MembershipObject) *Membership {
	if obj == nil {
		return nil
	}

	model := &Membership{
		GroupID:        obj.GetGroupId(),
		ProfileID:      obj.GetProfileId(),
		Name:           obj.GetName(),
		ContactID:      obj.GetContactId(),
		Role:           obj.GetRole(),
		MembershipType: obj.GetMembershipType(),
		OrderNo:        obj.GetOrderNo(),
		State:          int32(obj.GetState()),
	}

	if obj.GetProperties() != nil {
		model.Properties = (&data.JSONMap{}).FromProtoStruct(obj.GetProperties())
	}

	model.GenID(ctx)
	if model.ValidXID(obj.GetId()) {
		model.ID = obj.GetId()
	}

	return model
}

// ClientAssignmentHistory records deprecated client-to-agent reassignment events.
type ClientAssignmentHistory struct {
	data.BaseModel
	ClientID        string `gorm:"type:varchar(50);index:idx_cah_client"`
	PreviousAgentID string `gorm:"type:varchar(50)"`
	NewAgentID      string `gorm:"type:varchar(50)"`
	Reason          string `gorm:"type:text"`
}

func (m *ClientAssignmentHistory) TableName() string { return "client_assignment_history" }

// ClientResponsibilityHistory records changes to canonical team ownership and relationship handling.
type ClientResponsibilityHistory struct {
	data.BaseModel
	ClientID               string `gorm:"type:varchar(50);index:idx_crh_client"`
	PreviousOwningTeamID   string `gorm:"type:varchar(50)"`
	NewOwningTeamID        string `gorm:"type:varchar(50)"`
	PreviousRelationshipID string `gorm:"type:varchar(50)"`
	NewRelationshipID      string `gorm:"type:varchar(50)"`
	Reason                 string `gorm:"type:text"`
	AssignmentKind         string `gorm:"type:varchar(50);index:idx_crh_assignment_kind"`
}

func (m *ClientResponsibilityHistory) TableName() string { return "client_responsibility_history" }

// Investor represents an independent investor linked to a profile.
type Investor struct {
	data.BaseModel
	ProfileID  string `gorm:"type:varchar(50);uniqueIndex:uq_investor_profile"`
	Name       string `gorm:"type:varchar(255)"`
	State      int32
	Properties data.JSONMap
}

func (m *Investor) TableName() string { return "investors" }

func (m *Investor) ToAPI() *identityv1.InvestorObject {
	return &identityv1.InvestorObject{
		Id:         m.GetID(),
		ProfileId:  m.ProfileID,
		Name:       m.Name,
		State:      commonv1.STATE(m.State),
		Properties: m.Properties.ToProtoStruct(),
	}
}

func InvestorFromAPI(ctx context.Context, obj *identityv1.InvestorObject) *Investor {
	if obj == nil {
		return nil
	}

	model := &Investor{
		ProfileID: obj.GetProfileId(),
		Name:      obj.GetName(),
		State:     int32(obj.GetState()),
	}

	if obj.GetProperties() != nil {
		model.Properties = (&data.JSONMap{}).FromProtoStruct(obj.GetProperties())
	}

	model.GenID(ctx)
	if model.ValidXID(obj.GetId()) {
		model.ID = obj.GetId()
	}

	return model
}

// WorkforceMember represents a worker in the organization.
type WorkforceMember struct {
	data.BaseModel
	OrganizationID string `gorm:"type:varchar(50);index:idx_workforce_member_organization;not null"`
	ProfileID      string `gorm:"type:varchar(50);index:idx_workforce_member_profile"`
	EngagementType string `gorm:"type:varchar(50)"` // organization-defined (e.g. "employee", "agent", "contractor")
	HomeOrgUnitID  string `gorm:"type:varchar(50);index:idx_workforce_member_home_org_unit"`
	GeoID          string `gorm:"type:varchar(50)"`
	State          int32
	Properties     data.JSONMap
}

func (m *WorkforceMember) TableName() string { return "workforce_members" }

func (m *WorkforceMember) ToAPI() *identityv1.WorkforceMemberObject {
	return &identityv1.WorkforceMemberObject{
		Id:             m.GetID(),
		OrganizationId: m.OrganizationID,
		ProfileId:      m.ProfileID,
		EngagementType: m.EngagementType,
		HomeOrgUnitId:  m.HomeOrgUnitID,
		GeoId:          m.GeoID,
		State:          commonv1.STATE(m.State),
		Properties:     m.Properties.ToProtoStruct(),
	}
}

func WorkforceMemberFromAPI(ctx context.Context, obj *identityv1.WorkforceMemberObject) *WorkforceMember {
	if obj == nil {
		return nil
	}

	model := &WorkforceMember{
		OrganizationID: obj.GetOrganizationId(),
		ProfileID:      obj.GetProfileId(),
		EngagementType: obj.GetEngagementType(),
		HomeOrgUnitID:  obj.GetHomeOrgUnitId(),
		GeoID:          obj.GetGeoId(),
		State:          int32(obj.GetState()),
	}

	if obj.GetProperties() != nil {
		model.Properties = (&data.JSONMap{}).FromProtoStruct(obj.GetProperties())
	}

	model.GenID(ctx)
	if model.ValidXID(obj.GetId()) {
		model.ID = obj.GetId()
	}

	return model
}

// Department represents a functional grouping node.
type Department struct {
	data.BaseModel
	OrganizationID string `gorm:"type:varchar(50);index:idx_department_organization;uniqueIndex:uq_department_org_code,priority:1;uniqueIndex:uq_department_org_name,priority:1;not null"`
	ParentID       string `gorm:"type:varchar(50);index:idx_department_parent"`
	Kind           int32
	Name           string `gorm:"type:varchar(255);uniqueIndex:uq_department_org_name,priority:2"`
	Code           string `gorm:"type:varchar(50);uniqueIndex:uq_department_org_code,priority:2"`
	State          int32
	Properties     data.JSONMap
}

func (m *Department) TableName() string { return "departments" }

func (m *Department) ToAPI() *identityv1.DepartmentObject {
	return &identityv1.DepartmentObject{
		Id:             m.GetID(),
		OrganizationId: m.OrganizationID,
		ParentId:       m.ParentID,
		Kind:           identityv1.DepartmentKind(m.Kind),
		Name:           m.Name,
		Code:           m.Code,
		State:          commonv1.STATE(m.State),
		Properties:     m.Properties.ToProtoStruct(),
	}
}

func DepartmentFromAPI(ctx context.Context, obj *identityv1.DepartmentObject) *Department {
	if obj == nil {
		return nil
	}

	model := &Department{
		OrganizationID: obj.GetOrganizationId(),
		ParentID:       obj.GetParentId(),
		Kind:           int32(obj.GetKind()),
		Name:           obj.GetName(),
		Code:           obj.GetCode(),
		State:          int32(obj.GetState()),
	}

	if obj.GetProperties() != nil {
		model.Properties = (&data.JSONMap{}).FromProtoStruct(obj.GetProperties())
	}

	model.GenID(ctx)
	if model.ValidXID(obj.GetId()) {
		model.ID = obj.GetId()
	}

	return model
}

// Position represents a reporting seat in the organization.
type Position struct {
	data.BaseModel
	OrganizationID      string `gorm:"type:varchar(50);index:idx_position_organization;uniqueIndex:uq_position_org_code;not null"`
	OrgUnitID           string `gorm:"type:varchar(50);index:idx_position_org_unit"`
	DepartmentID        string `gorm:"type:varchar(50);index:idx_position_department"`
	ReportsToPositionID string `gorm:"type:varchar(50);index:idx_position_reports_to"`
	Name                string `gorm:"type:varchar(255)"`
	Code                string `gorm:"type:varchar(50);uniqueIndex:uq_position_org_code"`
	State               int32
	Properties          data.JSONMap
}

func (m *Position) TableName() string { return "positions" }

func (m *Position) ToAPI() *identityv1.PositionObject {
	return &identityv1.PositionObject{
		Id:                  m.GetID(),
		OrganizationId:      m.OrganizationID,
		OrgUnitId:           m.OrgUnitID,
		DepartmentId:        m.DepartmentID,
		ReportsToPositionId: m.ReportsToPositionID,
		Name:                m.Name,
		Code:                m.Code,
		State:               commonv1.STATE(m.State),
		Properties:          m.Properties.ToProtoStruct(),
	}
}

func PositionFromAPI(ctx context.Context, obj *identityv1.PositionObject) *Position {
	if obj == nil {
		return nil
	}

	model := &Position{
		OrganizationID:      obj.GetOrganizationId(),
		OrgUnitID:           obj.GetOrgUnitId(),
		DepartmentID:        obj.GetDepartmentId(),
		ReportsToPositionID: obj.GetReportsToPositionId(),
		Name:                obj.GetName(),
		Code:                obj.GetCode(),
		State:               int32(obj.GetState()),
	}

	if obj.GetProperties() != nil {
		model.Properties = (&data.JSONMap{}).FromProtoStruct(obj.GetProperties())
	}

	model.GenID(ctx)
	if model.ValidXID(obj.GetId()) {
		model.ID = obj.GetId()
	}

	return model
}

// PositionAssignment assigns a workforce member to a position.
type PositionAssignment struct {
	data.BaseModel
	MemberID   string `gorm:"type:varchar(50);index:idx_position_assignment_member;not null"`
	PositionID string `gorm:"type:varchar(50);index:idx_position_assignment_position;not null"`
	IsPrimary  bool   `gorm:"index:idx_position_assignment_primary"`
	State      int32
	Properties data.JSONMap
}

func (m *PositionAssignment) TableName() string { return "position_assignments" }

func (m *PositionAssignment) ToAPI() *identityv1.PositionAssignmentObject {
	return &identityv1.PositionAssignmentObject{
		Id:         m.GetID(),
		MemberId:   m.MemberID,
		PositionId: m.PositionID,
		IsPrimary:  m.IsPrimary,
		State:      commonv1.STATE(m.State),
		Properties: m.Properties.ToProtoStruct(),
	}
}

func PositionAssignmentFromAPI(ctx context.Context, obj *identityv1.PositionAssignmentObject) *PositionAssignment {
	if obj == nil {
		return nil
	}

	model := &PositionAssignment{
		MemberID:   obj.GetMemberId(),
		PositionID: obj.GetPositionId(),
		IsPrimary:  obj.GetIsPrimary(),
		State:      int32(obj.GetState()),
	}

	if obj.GetProperties() != nil {
		model.Properties = (&data.JSONMap{}).FromProtoStruct(obj.GetProperties())
	}

	model.GenID(ctx)
	if model.ValidXID(obj.GetId()) {
		model.ID = obj.GetId()
	}

	return model
}

// InternalTeam represents an execution team with a business objective.
type InternalTeam struct {
	data.BaseModel
	OrganizationID string `gorm:"type:varchar(50);index:idx_internal_team_organization;uniqueIndex:uq_internal_team_org_code,priority:1;uniqueIndex:uq_internal_team_org_name,priority:1;not null"`
	ParentTeamID   string `gorm:"type:varchar(50);index:idx_internal_team_parent"`
	HomeOrgUnitID  string `gorm:"type:varchar(50);index:idx_internal_team_org_unit"`
	Name           string `gorm:"type:varchar(255);uniqueIndex:uq_internal_team_org_name,priority:2"`
	Code           string `gorm:"type:varchar(50);uniqueIndex:uq_internal_team_org_code,priority:2"`
	TeamType       string `gorm:"type:varchar(50)"` // organization-defined (e.g. "portfolio", "collections", "agent_network")
	Objective      string `gorm:"type:text"`
	GeoID          string `gorm:"type:varchar(50)"`
	State          int32
	Properties     data.JSONMap
}

func (m *InternalTeam) TableName() string { return "internal_teams" }

func (m *InternalTeam) ToAPI() *identityv1.InternalTeamObject {
	return &identityv1.InternalTeamObject{
		Id:             m.GetID(),
		OrganizationId: m.OrganizationID,
		ParentTeamId:   m.ParentTeamID,
		HomeOrgUnitId:  m.HomeOrgUnitID,
		Name:           m.Name,
		Code:           m.Code,
		TeamType:       m.TeamType,
		Objective:      m.Objective,
		GeoId:          m.GeoID,
		State:          commonv1.STATE(m.State),
		Properties:     m.Properties.ToProtoStruct(),
	}
}

func InternalTeamFromAPI(ctx context.Context, obj *identityv1.InternalTeamObject) *InternalTeam {
	if obj == nil {
		return nil
	}

	model := &InternalTeam{
		OrganizationID: obj.GetOrganizationId(),
		ParentTeamID:   obj.GetParentTeamId(),
		HomeOrgUnitID:  obj.GetHomeOrgUnitId(),
		Name:           obj.GetName(),
		Code:           obj.GetCode(),
		TeamType:       obj.GetTeamType(),
		Objective:      obj.GetObjective(),
		GeoID:          obj.GetGeoId(),
		State:          int32(obj.GetState()),
	}

	if obj.GetProperties() != nil {
		model.Properties = (&data.JSONMap{}).FromProtoStruct(obj.GetProperties())
	}

	model.GenID(ctx)
	if model.ValidXID(obj.GetId()) {
		model.ID = obj.GetId()
	}

	return model
}

// TeamMembership assigns a workforce member to an internal team.
type TeamMembership struct {
	data.BaseModel
	TeamID         string `gorm:"type:varchar(50);index:idx_team_membership_team;not null"`
	MemberID       string `gorm:"type:varchar(50);index:idx_team_membership_member;not null"`
	MembershipRole string `gorm:"type:varchar(50)"` // organization-defined (e.g. "lead", "member", "supervisor")
	IsPrimaryTeam  bool   `gorm:"index:idx_team_membership_primary"`
	State          int32
	Properties     data.JSONMap
}

func (m *TeamMembership) TableName() string { return "team_memberships" }

func (m *TeamMembership) ToAPI() *identityv1.TeamMembershipObject {
	return &identityv1.TeamMembershipObject{
		Id:             m.GetID(),
		TeamId:         m.TeamID,
		MemberId:       m.MemberID,
		MembershipRole: m.MembershipRole,
		IsPrimaryTeam:  m.IsPrimaryTeam,
		State:          commonv1.STATE(m.State),
		Properties:     m.Properties.ToProtoStruct(),
	}
}

func TeamMembershipFromAPI(ctx context.Context, obj *identityv1.TeamMembershipObject) *TeamMembership {
	if obj == nil {
		return nil
	}

	model := &TeamMembership{
		TeamID:         obj.GetTeamId(),
		MemberID:       obj.GetMemberId(),
		MembershipRole: obj.GetMembershipRole(),
		IsPrimaryTeam:  obj.GetIsPrimaryTeam(),
		State:          int32(obj.GetState()),
	}

	if obj.GetProperties() != nil {
		model.Properties = (&data.JSONMap{}).FromProtoStruct(obj.GetProperties())
	}

	model.GenID(ctx)
	if model.ValidXID(obj.GetId()) {
		model.ID = obj.GetId()
	}

	return model
}

// AccessRoleAssignment grants explicit authorization at a given scope.
type AccessRoleAssignment struct {
	data.BaseModel
	MemberID   string `gorm:"type:varchar(50);index:idx_access_role_assignment_member;not null"`
	RoleKey    string `gorm:"type:varchar(100);index:idx_access_role_assignment_role;not null"`
	ScopeType  int32  `gorm:"index:idx_access_role_assignment_scope"`
	ScopeID    string `gorm:"type:varchar(50);index:idx_access_role_assignment_scope"`
	State      int32
	Properties data.JSONMap
}

func (m *AccessRoleAssignment) TableName() string { return "access_role_assignments" }

func (m *AccessRoleAssignment) ToAPI() *identityv1.AccessRoleAssignmentObject {
	return &identityv1.AccessRoleAssignmentObject{
		Id:         m.GetID(),
		MemberId:   m.MemberID,
		RoleKey:    m.RoleKey,
		ScopeType:  identityv1.AccessScopeType(m.ScopeType),
		ScopeId:    m.ScopeID,
		State:      commonv1.STATE(m.State),
		Properties: m.Properties.ToProtoStruct(),
	}
}

func AccessRoleAssignmentFromAPI(
	ctx context.Context,
	obj *identityv1.AccessRoleAssignmentObject,
) *AccessRoleAssignment {
	if obj == nil {
		return nil
	}

	model := &AccessRoleAssignment{
		MemberID:  obj.GetMemberId(),
		RoleKey:   obj.GetRoleKey(),
		ScopeType: int32(obj.GetScopeType()),
		ScopeID:   obj.GetScopeId(),
		State:     int32(obj.GetState()),
	}

	if obj.GetProperties() != nil {
		model.Properties = (&data.JSONMap{}).FromProtoStruct(obj.GetProperties())
	}

	model.GenID(ctx)
	if model.ValidXID(obj.GetId()) {
		model.ID = obj.GetId()
	}

	return model
}

// ClientDataEntry stores a single piece of client KYC data.
// The (ClientID, FieldKey) pair is unique — resubmissions increment Revision.
type ClientDataEntry struct {
	data.BaseModel
	ClientID           string `gorm:"type:varchar(50);uniqueIndex:uq_cde_client_key,priority:1;not null"`
	FieldKey           string `gorm:"type:varchar(100);uniqueIndex:uq_cde_client_key,priority:2;not null"`
	Value              string `gorm:"type:text"`
	ValueType          string `gorm:"type:varchar(20)"`
	VerificationStatus int32  // matches DataVerificationStatus enum
	ReviewerID         string `gorm:"type:varchar(50)"`
	ReviewerComment    string `gorm:"type:text"`
	SourceEntityID     string `gorm:"type:varchar(50)"`
	Revision           int32
	VerifiedAt         *time.Time
	ExpiresAt          *time.Time
	Properties         data.JSONMap
}

func (m *ClientDataEntry) TableName() string { return "client_data_entries" }

func (m *ClientDataEntry) ToAPI() *identityv1.ClientDataEntryObject {
	obj := &identityv1.ClientDataEntryObject{
		Id:                 m.GetID(),
		ClientId:           m.ClientID,
		FieldKey:           m.FieldKey,
		Value:              m.Value,
		ValueType:          m.ValueType,
		VerificationStatus: identityv1.DataVerificationStatus(m.VerificationStatus),
		ReviewerId:         m.ReviewerID,
		ReviewerComment:    m.ReviewerComment,
		SourceEntityId:     m.SourceEntityID,
		Revision:           m.Revision,
		Properties:         m.Properties.ToProtoStruct(),
	}
	if m.VerifiedAt != nil {
		obj.VerifiedAt = m.VerifiedAt.Format(time.RFC3339)
	}
	if m.ExpiresAt != nil {
		obj.ExpiresAt = m.ExpiresAt.Format(time.RFC3339)
	}
	return obj
}

func ClientDataEntryFromAPI(ctx context.Context, obj *identityv1.ClientDataEntryObject) *ClientDataEntry {
	if obj == nil {
		return nil
	}

	model := &ClientDataEntry{
		ClientID:           obj.GetClientId(),
		FieldKey:           obj.GetFieldKey(),
		Value:              obj.GetValue(),
		ValueType:          obj.GetValueType(),
		VerificationStatus: int32(obj.GetVerificationStatus()),
		ReviewerID:         obj.GetReviewerId(),
		ReviewerComment:    obj.GetReviewerComment(),
		SourceEntityID:     obj.GetSourceEntityId(),
		Revision:           obj.GetRevision(),
	}

	if obj.GetProperties() != nil {
		model.Properties = (&data.JSONMap{}).FromProtoStruct(obj.GetProperties())
	}

	if obj.GetVerifiedAt() != "" {
		if t, err := time.Parse(time.RFC3339, obj.GetVerifiedAt()); err == nil {
			model.VerifiedAt = &t
		}
	}
	if obj.GetExpiresAt() != "" {
		if t, err := time.Parse(time.RFC3339, obj.GetExpiresAt()); err == nil {
			model.ExpiresAt = &t
		}
	}

	model.GenID(ctx)
	if model.ValidXID(obj.GetId()) {
		model.ID = obj.GetId()
	}

	return model
}

// ClientDataEntryHistory tracks every action on a data entry.
type ClientDataEntryHistory struct {
	data.BaseModel
	EntryID  string `gorm:"type:varchar(50);index:idx_cdeh_entry;not null"`
	Revision int32
	Value    string `gorm:"type:text"`
	Action   string `gorm:"type:varchar(20)"` // submitted, verified, rejected, more_info, expired
	ActorID  string `gorm:"type:varchar(50)"`
	Comment  string `gorm:"type:text"`
}

func (m *ClientDataEntryHistory) TableName() string { return "client_data_entry_history" }

func (m *ClientDataEntryHistory) ToAPI() *identityv1.ClientDataEntryHistoryObject {
	return &identityv1.ClientDataEntryHistoryObject{
		Id:        m.GetID(),
		EntryId:   m.EntryID,
		Revision:  m.Revision,
		Value:     m.Value,
		Action:    m.Action,
		ActorId:   m.ActorID,
		Comment:   m.Comment,
		CreatedAt: m.CreatedAt.Format(time.RFC3339),
	}
}

func ClientDataEntryHistoryFromAPI(
	ctx context.Context,
	obj *identityv1.ClientDataEntryHistoryObject,
) *ClientDataEntryHistory {
	if obj == nil {
		return nil
	}

	model := &ClientDataEntryHistory{
		EntryID:  obj.GetEntryId(),
		Revision: obj.GetRevision(),
		Value:    obj.GetValue(),
		Action:   obj.GetAction(),
		ActorID:  obj.GetActorId(),
		Comment:  obj.GetComment(),
	}

	model.GenID(ctx)
	if model.ValidXID(obj.GetId()) {
		model.ID = obj.GetId()
	}

	return model
}
