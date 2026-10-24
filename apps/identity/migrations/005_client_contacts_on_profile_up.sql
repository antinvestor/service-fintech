-- Contacts belong to the borrower's profile (profile service), never to the
-- client row. Clients registered before this kept the phone they were
-- registered with in properties; every such client already has a profile
-- carrying that contact, so the copy is dropped. Open phone-change cases are
-- closed: contact changes now happen on the profile.
UPDATE clients
   SET properties = properties - 'phone_number' - 'phone' - 'pending_phone_number',
       modified_at = now()
 WHERE profile_id <> ''
   AND (properties ? 'phone_number' OR properties ? 'phone' OR properties ? 'pending_phone_number');

UPDATE approval_cases
   SET status = 'rejected',
       comment = 'contact changes are made on the profile',
       modified_at = now()
 WHERE case_type = 'client_phone_change'
   AND status IN ('pending_verification', 'pending_approval')
   AND deleted_at IS NULL;
