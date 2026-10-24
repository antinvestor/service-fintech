## 0.6.0

- Add ClientDataListResponse.next_cursor
- Deprecate reviewer_id on ClientDataVerify/Reject/RequestInfo (reviewer derived from claims)
- Add ClientGroupSearch and MembershipSearch filter fields
- Deprecate identity InvestorAccount RPCs (owned by funding); role bindings dropped
- Add max_len validation on organization and org-unit name/code, cursor limit lte 200
- Regenerated from latest proto definitions

## 0.5.0

- Add OrganizationType values TRADING, RETAIL, MANUFACTURING, LOGISTICS, SERVICES
- Regenerated from latest proto definitions (partition_id optional on organization create)

## 0.4.0

- Add domain field to OrganizationObject (field 13)
- Regenerated from latest proto definitions

## 0.3.0

- Add OrganizationObject properties, client_id, partition_id fields
- Add workforce member, internal team, access role assignment messages

## 0.2.0

- Add form template and submission messages

## 0.1.0

- Generated Dart SDK from proto definitions
