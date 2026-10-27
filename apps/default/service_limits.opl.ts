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

import { Namespace, Context } from "@ory/keto-namespace-types"

class profile_user implements Namespace {}

class tenancy_access implements Namespace {
  related: {
    member: (profile_user | tenancy_access)[]
    service: profile_user[]
  }
}

class service_limits implements Namespace {
  related: {
    owner: profile_user[]
    admin: profile_user[]
    operator: profile_user[]
    viewer: profile_user[]
    member: profile_user[]
    service: (profile_user | tenancy_access)[]

    granted_limits_use: (profile_user | service_limits)[]
    granted_limits_policy_manage: (profile_user | service_limits)[]
    granted_limits_policy_view: (profile_user | service_limits)[]
    granted_limits_approval_view: (profile_user | service_limits)[]
    granted_limits_approval_act: (profile_user | service_limits)[]
    granted_limits_approval_override: (profile_user | service_limits)[]
    granted_limits_ledger_view: (profile_user | service_limits)[]
    granted_limits_audit_view: (profile_user | service_limits)[]
    granted_limits_archive: (profile_user | service_limits)[]
    granted_limits_job_run: (profile_user | service_limits)[]
  }

  permits = {
    limits_use: (ctx: Context): boolean =>
      this.related.admin.includes(ctx.subject) ||
      this.related.owner.includes(ctx.subject) ||
      this.related.service.includes(ctx.subject) ||
      this.related.granted_limits_use.includes(ctx.subject),

    limits_policy_manage: (ctx: Context): boolean =>
      this.related.admin.includes(ctx.subject) ||
      this.related.owner.includes(ctx.subject) ||
      this.related.granted_limits_policy_manage.includes(ctx.subject),

    limits_policy_view: (ctx: Context): boolean =>
      this.related.admin.includes(ctx.subject) ||
      this.related.member.includes(ctx.subject) ||
      this.related.operator.includes(ctx.subject) ||
      this.related.owner.includes(ctx.subject) ||
      this.related.viewer.includes(ctx.subject) ||
      this.related.granted_limits_policy_view.includes(ctx.subject),

    limits_approval_view: (ctx: Context): boolean =>
      this.related.admin.includes(ctx.subject) ||
      this.related.member.includes(ctx.subject) ||
      this.related.operator.includes(ctx.subject) ||
      this.related.owner.includes(ctx.subject) ||
      this.related.viewer.includes(ctx.subject) ||
      this.related.granted_limits_approval_view.includes(ctx.subject),

    limits_approval_act: (ctx: Context): boolean =>
      this.related.admin.includes(ctx.subject) ||
      this.related.operator.includes(ctx.subject) ||
      this.related.owner.includes(ctx.subject) ||
      this.related.granted_limits_approval_act.includes(ctx.subject),

    limits_approval_override: (ctx: Context): boolean =>
      this.related.admin.includes(ctx.subject) ||
      this.related.owner.includes(ctx.subject) ||
      this.related.granted_limits_approval_override.includes(ctx.subject),

    limits_ledger_view: (ctx: Context): boolean =>
      this.related.admin.includes(ctx.subject) ||
      this.related.member.includes(ctx.subject) ||
      this.related.operator.includes(ctx.subject) ||
      this.related.owner.includes(ctx.subject) ||
      this.related.viewer.includes(ctx.subject) ||
      this.related.granted_limits_ledger_view.includes(ctx.subject),

    limits_audit_view: (ctx: Context): boolean =>
      this.related.admin.includes(ctx.subject) ||
      this.related.member.includes(ctx.subject) ||
      this.related.operator.includes(ctx.subject) ||
      this.related.owner.includes(ctx.subject) ||
      this.related.viewer.includes(ctx.subject) ||
      this.related.granted_limits_audit_view.includes(ctx.subject),

    limits_archive: (ctx: Context): boolean =>
      this.related.granted_limits_archive.includes(ctx.subject),

    limits_job_run: (ctx: Context): boolean =>
      this.related.granted_limits_job_run.includes(ctx.subject),
  }
}
