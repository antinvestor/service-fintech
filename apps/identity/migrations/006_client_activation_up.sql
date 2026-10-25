-- A client registered by a field agent now starts CREATED and becomes ACTIVE
-- only when activated: its KYC fully verified and, for an agent, the
-- person's consent code entered. Every client stored before this either
-- passed the consent gate at registration or was registered by staff, so
-- the ones still CREATED (state 0, the proto default) are treated as
-- activated.
UPDATE clients
   SET state = 2,
       modified_at = now()
 WHERE state = 0
   AND deleted_at IS NULL;
