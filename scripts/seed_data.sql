-- TraceConnect seed data — 18 conversations across 3 branches.
-- Run: psql -h aws-1-eu-west-1.pooler.supabase.com -p 5432 -U postgres.aufoguugseioihxvtjpa -d postgres -f scripts/seed_data.sql

-- Helper: clean any existing seed data first
DELETE FROM attachments;
DELETE FROM analysis;
DELETE FROM dialog;
DELETE FROM party_history;
DELETE FROM parties;
DELETE FROM groups;
DELETE FROM vcons;

-- ============================================================
-- 1. SmartRouter Pro overheating — Lagos (Mon-Tue)
-- ============================================================

INSERT INTO vcons (id, uuid, vcon_version, subject, created_at, updated_at) VALUES
('a0000001-0000-0000-0000-000000000001', 'a0000001-0000-0000-0000-000000000001', '0.3.0',
 'SmartRouter Pro overheating after firmware update', NOW() - INTERVAL '4 days', NOW() - INTERVAL '4 days');

INSERT INTO parties (vcon_id, party_index, name, mailto, tel, metadata) VALUES
('a0000001-0000-0000-0000-000000000001', 0, 'Chioma Okafor', 'chioma@techcorp.ng', NULL, '{"role":"agent"}'),
('a0000001-0000-0000-0000-000000000001', 1, 'Kunle Adeyemi', NULL, '+234-801-555-0101', '{"role":"customer"}');

INSERT INTO dialog (vcon_id, dialog_index, type, body, encoding, parties, start_time) VALUES
('a0000001-0000-0000-0000-000000000001', 0, 'text', 'Good morning, my SmartRouter Pro has been overheating since the latest firmware update. It shuts down after 30 minutes.', 'none', ARRAY[1], NOW() - INTERVAL '4 days'),
('a0000001-0000-0000-0000-000000000001', 1, 'text', 'I understand your concern. Can you confirm the firmware version? We have received similar reports.', 'none', ARRAY[0], NOW() - INTERVAL '4 days' + INTERVAL '5 minutes'),
('a0000001-0000-0000-0000-000000000001', 2, 'text', 'Version 3.2.1, installed two days ago.', 'none', ARRAY[1], NOW() - INTERVAL '4 days' + INTERVAL '8 minutes'),
('a0000001-0000-0000-0000-000000000001', 3, 'text', 'Thank you. I am escalating this to our product team. Please roll back to version 3.1.8 for now.', 'none', ARRAY[0], NOW() - INTERVAL '4 days' + INTERVAL '12 minutes');

INSERT INTO analysis (vcon_id, analysis_index, type, vendor, product, body, encoding) VALUES
('a0000001-0000-0000-0000-000000000001', 0, 'summary', 'TraceConnect', 'AI Analysis', 'Customer reports SmartRouter Pro overheating after firmware 3.2.1 update. Agent advised rollback to 3.1.8 and escalated to product team.', 'none'),
('a0000001-0000-0000-0000-000000000001', 1, 'sentiment', 'TraceConnect', 'AI Analysis', '{"label":"negative","score":-0.6}', 'json');

INSERT INTO attachments (vcon_id, attachment_index, type, encoding, body) VALUES
('a0000001-0000-0000-0000-000000000001', 0, 'tags', 'json', '["branch:Lagos","status:open","priority:high","channel:call","issue_category:product_defect"]'),
('a0000001-0000-0000-0000-000000000001', 1, 'consent', 'json', '{"consent_given":true,"consent_purpose":"customer support analysis","consent_law":"Nigeria NDPR","consent_granted_date":"2026-02-03","consent_expiry_date":"2026-04-04"}');

-- ============================================================
-- 2. SmartRouter Pro shutting down — Lagos
-- ============================================================

INSERT INTO vcons (id, uuid, vcon_version, subject, created_at, updated_at) VALUES
('a0000002-0000-0000-0000-000000000002', 'a0000002-0000-0000-0000-000000000002', '0.3.0',
 'SmartRouter Pro shutting down due to heat', NOW() - INTERVAL '3 days', NOW() - INTERVAL '3 days');

INSERT INTO parties (vcon_id, party_index, name, mailto, tel, metadata) VALUES
('a0000002-0000-0000-0000-000000000002', 0, 'Emeka Nwosu', 'emeka@techcorp.ng', NULL, '{"role":"agent"}'),
('a0000002-0000-0000-0000-000000000002', 1, 'Blessing Igwe', NULL, '+234-802-555-0202', '{"role":"customer"}');

INSERT INTO dialog (vcon_id, dialog_index, type, body, encoding, parties, start_time) VALUES
('a0000002-0000-0000-0000-000000000002', 0, 'text', 'My SmartRouter Pro keeps shutting down. I think it is overheating. This started after an automatic update.', 'none', ARRAY[1], NOW() - INTERVAL '3 days'),
('a0000002-0000-0000-0000-000000000002', 1, 'text', 'Yes, we are aware of this issue with firmware 3.2.1. I will help you roll back immediately.', 'none', ARRAY[0], NOW() - INTERVAL '3 days' + INTERVAL '3 minutes');

INSERT INTO analysis (vcon_id, analysis_index, type, vendor, product, body, encoding) VALUES
('a0000002-0000-0000-0000-000000000002', 0, 'summary', 'TraceConnect', 'AI Analysis', 'Second report of SmartRouter Pro overheating in Lagos. Agent confirmed known firmware issue and initiated rollback.', 'none'),
('a0000002-0000-0000-0000-000000000002', 1, 'sentiment', 'TraceConnect', 'AI Analysis', '{"label":"negative","score":-0.5}', 'json');

INSERT INTO attachments (vcon_id, attachment_index, type, encoding, body) VALUES
('a0000002-0000-0000-0000-000000000002', 0, 'tags', 'json', '["branch:Lagos","status:in_progress","priority:high","channel:call","issue_category:product_defect"]'),
('a0000002-0000-0000-0000-000000000002', 1, 'consent', 'json', '{"consent_given":true,"consent_purpose":"customer support analysis","consent_law":"Nigeria NDPR","consent_granted_date":"2026-02-08","consent_expiry_date":"2026-04-09"}');

-- ============================================================
-- 3. SmartRouter Pro thermal warning — Lagos (with supervisor)
-- ============================================================

INSERT INTO vcons (id, uuid, vcon_version, subject, created_at, updated_at) VALUES
('a0000003-0000-0000-0000-000000000003', 'a0000003-0000-0000-0000-000000000003', '0.3.0',
 'SmartRouter Pro thermal warning — third report', NOW() - INTERVAL '3 days', NOW() - INTERVAL '2 days');

INSERT INTO parties (vcon_id, party_index, name, mailto, tel, metadata) VALUES
('a0000003-0000-0000-0000-000000000003', 0, 'Ngozi Eze', 'ngozi@techcorp.ng', NULL, '{"role":"agent"}'),
('a0000003-0000-0000-0000-000000000003', 1, 'Adebayo Ogundimu', 'adebayo@techcorp.ng', NULL, '{"role":"supervisor"}'),
('a0000003-0000-0000-0000-000000000003', 2, 'Tunde Bakare', NULL, '+234-803-555-0303', '{"role":"customer"}');

INSERT INTO dialog (vcon_id, dialog_index, type, body, encoding, parties, start_time) VALUES
('a0000003-0000-0000-0000-000000000003', 0, 'text', 'I bought the SmartRouter Pro last month and it is now showing a thermal warning light constantly.', 'none', ARRAY[2], NOW() - INTERVAL '3 days'),
('a0000003-0000-0000-0000-000000000003', 1, 'text', 'This is the third report we have received about this. I am escalating to supervisor Adebayo.', 'none', ARRAY[0], NOW() - INTERVAL '3 days' + INTERVAL '5 minutes'),
('a0000003-0000-0000-0000-000000000003', 2, 'text', 'Thank you Ngozi. Customer, we are treating this as a priority. Our product team is investigating the firmware update that caused this issue. We will contact you within 24 hours with a resolution.', 'none', ARRAY[1], NOW() - INTERVAL '2 days');

INSERT INTO analysis (vcon_id, analysis_index, type, vendor, product, body, encoding) VALUES
('a0000003-0000-0000-0000-000000000003', 0, 'summary', 'TraceConnect', 'AI Analysis', 'Third SmartRouter Pro overheating report in Lagos. Escalated to supervisor Adebayo. Product team investigating firmware 3.2.1.', 'none'),
('a0000003-0000-0000-0000-000000000003', 1, 'sentiment', 'TraceConnect', 'AI Analysis', '{"label":"negative","score":-0.7}', 'json');

INSERT INTO attachments (vcon_id, attachment_index, type, encoding, body) VALUES
('a0000003-0000-0000-0000-000000000003', 0, 'tags', 'json', '["branch:Lagos","status:in_progress","priority:high","channel:call","issue_category:product_defect"]'),
('a0000003-0000-0000-0000-000000000003', 1, 'consent', 'json', '{"consent_given":true,"consent_purpose":"customer support analysis","consent_law":"Nigeria NDPR","consent_granted_date":"2026-02-13","consent_expiry_date":"2026-04-14"}');

-- ============================================================
-- 4. SmartRouter Pro overheating — Nairobi (Wed)
-- ============================================================

INSERT INTO vcons (id, uuid, vcon_version, subject, created_at, updated_at) VALUES
('a0000004-0000-0000-0000-000000000004', 'a0000004-0000-0000-0000-000000000004', '0.3.0',
 'SmartRouter Pro overheating — same as Lagos reports', NOW() - INTERVAL '2 days', NOW() - INTERVAL '1 day');

INSERT INTO parties (vcon_id, party_index, name, mailto, tel, metadata) VALUES
('a0000004-0000-0000-0000-000000000004', 0, 'Amina Wanjiku', 'amina@techcorp.ke', NULL, '{"role":"agent"}'),
('a0000004-0000-0000-0000-000000000004', 1, 'Peter Kamau', NULL, '+254-722-555-0101', '{"role":"customer"}');

INSERT INTO dialog (vcon_id, dialog_index, type, body, encoding, parties, start_time) VALUES
('a0000004-0000-0000-0000-000000000004', 0, 'text', 'My SmartRouter Pro is overheating badly. I saw online that others in Nigeria are having the same problem.', 'none', ARRAY[1], NOW() - INTERVAL '2 days'),
('a0000004-0000-0000-0000-000000000004', 1, 'text', 'Thank you for letting us know. We are aware of this issue affecting the latest firmware. I will apply the fix immediately.', 'none', ARRAY[0], NOW() - INTERVAL '2 days' + INTERVAL '10 minutes'),
('a0000004-0000-0000-0000-000000000004', 2, 'text', 'The rollback is complete. Please monitor and let us know if the issue persists.', 'none', ARRAY[0], NOW() - INTERVAL '1 day');

INSERT INTO analysis (vcon_id, analysis_index, type, vendor, product, body, encoding) VALUES
('a0000004-0000-0000-0000-000000000004', 0, 'summary', 'TraceConnect', 'AI Analysis', 'SmartRouter Pro overheating reported in Nairobi — same firmware 3.2.1 issue as Lagos. Agent Amina resolved with rollback in 1 hour.', 'none'),
('a0000004-0000-0000-0000-000000000004', 1, 'sentiment', 'TraceConnect', 'AI Analysis', '{"label":"positive","score":0.3}', 'json');

INSERT INTO attachments (vcon_id, attachment_index, type, encoding, body) VALUES
('a0000004-0000-0000-0000-000000000004', 0, 'tags', 'json', '["branch:Nairobi","status:resolved","priority:high","channel:call","issue_category:product_defect"]'),
('a0000004-0000-0000-0000-000000000004', 1, 'consent', 'json', '{"consent_given":true,"consent_purpose":"customer support analysis","consent_law":"Kenya DPA","consent_granted_date":"2026-02-18","consent_expiry_date":"2026-04-19"}');

-- ============================================================
-- 5. SmartRouter Pro heat — Nairobi (chat)
-- ============================================================

INSERT INTO vcons (id, uuid, vcon_version, subject, created_at, updated_at) VALUES
('a0000005-0000-0000-0000-000000000005', 'a0000005-0000-0000-0000-000000000005', '0.3.0',
 'SmartRouter Pro heat issue after update', NOW() - INTERVAL '1 day', NOW() - INTERVAL '6 hours');

INSERT INTO parties (vcon_id, party_index, name, mailto, tel, metadata) VALUES
('a0000005-0000-0000-0000-000000000005', 0, 'Joseph Ochieng', 'joseph@techcorp.ke', NULL, '{"role":"agent"}'),
('a0000005-0000-0000-0000-000000000005', 1, 'Grace Muthoni', NULL, '+254-733-555-0202', '{"role":"customer"}');

INSERT INTO dialog (vcon_id, dialog_index, type, body, encoding, parties, start_time) VALUES
('a0000005-0000-0000-0000-000000000005', 0, 'text', 'Hello, my router started overheating yesterday. Is there a known issue?', 'none', ARRAY[1], NOW() - INTERVAL '1 day'),
('a0000005-0000-0000-0000-000000000005', 1, 'text', 'Yes, we have identified a firmware issue. Let me fix this for you right away.', 'none', ARRAY[0], NOW() - INTERVAL '1 day' + INTERVAL '2 minutes'),
('a0000005-0000-0000-0000-000000000005', 2, 'text', 'Done. Your router has been rolled back to a stable version. You should be good now.', 'none', ARRAY[0], NOW() - INTERVAL '6 hours');

INSERT INTO analysis (vcon_id, analysis_index, type, vendor, product, body, encoding) VALUES
('a0000005-0000-0000-0000-000000000005', 0, 'summary', 'TraceConnect', 'AI Analysis', 'Fifth SmartRouter Pro overheating report, second in Nairobi. Joseph resolved quickly via chat.', 'none'),
('a0000005-0000-0000-0000-000000000005', 1, 'sentiment', 'TraceConnect', 'AI Analysis', '{"label":"positive","score":0.5}', 'json');

INSERT INTO attachments (vcon_id, attachment_index, type, encoding, body) VALUES
('a0000005-0000-0000-0000-000000000005', 0, 'tags', 'json', '["branch:Nairobi","status:resolved","priority:high","channel:chat","issue_category:product_defect"]'),
('a0000005-0000-0000-0000-000000000005', 1, 'consent', 'json', '{"consent_given":true,"consent_purpose":"customer support analysis","consent_law":"Kenya DPA","consent_granted_date":"2026-02-23","consent_expiry_date":"2026-04-24"}');

-- ============================================================
-- 6. Billing — Nairobi (resolved fast, 2h)
-- ============================================================

INSERT INTO vcons (id, uuid, vcon_version, subject, created_at, updated_at) VALUES
('a0000006-0000-0000-0000-000000000006', 'a0000006-0000-0000-0000-000000000006', '0.3.0',
 'Incorrect charge on monthly invoice', NOW() - INTERVAL '5 days', NOW() - INTERVAL '5 days' + INTERVAL '2 hours');

INSERT INTO parties (vcon_id, party_index, name, mailto, tel, metadata) VALUES
('a0000006-0000-0000-0000-000000000006', 0, 'Amina Wanjiku', 'amina@techcorp.ke', NULL, '{"role":"agent"}'),
('a0000006-0000-0000-0000-000000000006', 1, 'Daniel Kiprop', 'daniel.k@email.com', NULL, '{"role":"customer"}');

INSERT INTO dialog (vcon_id, dialog_index, type, body, encoding, parties, start_time) VALUES
('a0000006-0000-0000-0000-000000000006', 0, 'text', 'I have been charged twice for my subscription this month. Can you fix this?', 'none', ARRAY[1], NOW() - INTERVAL '5 days'),
('a0000006-0000-0000-0000-000000000006', 1, 'text', 'I can see the duplicate charge. Let me process a refund right away. It will reflect in 24 hours.', 'none', ARRAY[0], NOW() - INTERVAL '5 days' + INTERVAL '30 minutes'),
('a0000006-0000-0000-0000-000000000006', 2, 'text', 'Refund processed. Is there anything else I can help with?', 'none', ARRAY[0], NOW() - INTERVAL '5 days' + INTERVAL '2 hours');

INSERT INTO analysis (vcon_id, analysis_index, type, vendor, product, body, encoding) VALUES
('a0000006-0000-0000-0000-000000000006', 0, 'summary', 'TraceConnect', 'AI Analysis', 'Customer reported duplicate charge. Agent Amina resolved with immediate refund within 2 hours.', 'none'),
('a0000006-0000-0000-0000-000000000006', 1, 'sentiment', 'TraceConnect', 'AI Analysis', '{"label":"positive","score":0.7}', 'json');

INSERT INTO attachments (vcon_id, attachment_index, type, encoding, body) VALUES
('a0000006-0000-0000-0000-000000000006', 0, 'tags', 'json', '["branch:Nairobi","status:resolved","priority:medium","channel:email","issue_category:billing"]'),
('a0000006-0000-0000-0000-000000000006', 1, 'consent', 'json', '{"consent_given":true,"consent_purpose":"customer support analysis","consent_law":"Kenya DPA","consent_granted_date":"2026-01-04","consent_expiry_date":"2026-03-06"}');

-- ============================================================
-- 7. Billing — Nairobi (resolved fast, 3h)
-- ============================================================

INSERT INTO vcons (id, uuid, vcon_version, subject, created_at, updated_at) VALUES
('a0000007-0000-0000-0000-000000000007', 'a0000007-0000-0000-0000-000000000007', '0.3.0',
 'Billing discrepancy on enterprise plan', NOW() - INTERVAL '4 days', NOW() - INTERVAL '4 days' + INTERVAL '3 hours');

INSERT INTO parties (vcon_id, party_index, name, mailto, tel, metadata) VALUES
('a0000007-0000-0000-0000-000000000007', 0, 'Wanjiku Njeri', 'wanjiku@techcorp.ke', NULL, '{"role":"agent"}'),
('a0000007-0000-0000-0000-000000000007', 1, 'Samuel Otieno', 'samuel.o@company.co.ke', NULL, '{"role":"customer"}');

INSERT INTO dialog (vcon_id, dialog_index, type, body, encoding, parties, start_time) VALUES
('a0000007-0000-0000-0000-000000000007', 0, 'text', 'Our company was charged for 50 licenses but we only have 35 active users.', 'none', ARRAY[1], NOW() - INTERVAL '4 days'),
('a0000007-0000-0000-0000-000000000007', 1, 'text', 'I see the discrepancy. Inactive users were not removed during the last audit. I will correct this and issue a credit note.', 'none', ARRAY[0], NOW() - INTERVAL '4 days' + INTERVAL '1 hour'),
('a0000007-0000-0000-0000-000000000007', 2, 'text', 'Credit note issued for the difference. Your next invoice will reflect the correct count.', 'none', ARRAY[0], NOW() - INTERVAL '4 days' + INTERVAL '3 hours');

INSERT INTO analysis (vcon_id, analysis_index, type, vendor, product, body, encoding) VALUES
('a0000007-0000-0000-0000-000000000007', 0, 'summary', 'TraceConnect', 'AI Analysis', 'Enterprise customer overcharged for inactive licenses. Wanjiku resolved same day with credit note.', 'none'),
('a0000007-0000-0000-0000-000000000007', 1, 'sentiment', 'TraceConnect', 'AI Analysis', '{"label":"positive","score":0.6}', 'json');

INSERT INTO attachments (vcon_id, attachment_index, type, encoding, body) VALUES
('a0000007-0000-0000-0000-000000000007', 0, 'tags', 'json', '["branch:Nairobi","status:resolved","priority:medium","channel:email","issue_category:billing"]'),
('a0000007-0000-0000-0000-000000000007', 1, 'consent', 'json', '{"consent_given":true,"consent_purpose":"customer support analysis","consent_law":"Kenya DPA","consent_granted_date":"2026-01-19","consent_expiry_date":"2026-03-20"}');

-- ============================================================
-- 8. Billing — Nairobi (resolved fast, 1h)
-- ============================================================

INSERT INTO vcons (id, uuid, vcon_version, subject, created_at, updated_at) VALUES
('a0000008-0000-0000-0000-000000000008', 'a0000008-0000-0000-0000-000000000008', '0.3.0',
 'Unexpected pro-rata charges on upgrade', NOW() - INTERVAL '6 days', NOW() - INTERVAL '6 days' + INTERVAL '1 hour');

INSERT INTO parties (vcon_id, party_index, name, mailto, tel, metadata) VALUES
('a0000008-0000-0000-0000-000000000008', 0, 'Ochieng Odongo', 'ochieng@techcorp.ke', NULL, '{"role":"agent"}'),
('a0000008-0000-0000-0000-000000000008', 1, 'Mary Wambui', NULL, '+254-710-555-0303', '{"role":"customer"}');

INSERT INTO dialog (vcon_id, dialog_index, type, body, encoding, parties, start_time) VALUES
('a0000008-0000-0000-0000-000000000008', 0, 'text', 'I upgraded my plan last week but I was charged the full amount instead of the pro-rata difference.', 'none', ARRAY[1], NOW() - INTERVAL '6 days'),
('a0000008-0000-0000-0000-000000000008', 1, 'text', 'Let me check your account. Yes, the pro-rata calculation was not applied correctly. I will fix this now.', 'none', ARRAY[0], NOW() - INTERVAL '6 days' + INTERVAL '1 hour');

INSERT INTO analysis (vcon_id, analysis_index, type, vendor, product, body, encoding) VALUES
('a0000008-0000-0000-0000-000000000008', 0, 'summary', 'TraceConnect', 'AI Analysis', 'Pro-rata billing error on plan upgrade. Agent Ochieng corrected the charge within 1 hour.', 'none'),
('a0000008-0000-0000-0000-000000000008', 1, 'sentiment', 'TraceConnect', 'AI Analysis', '{"label":"neutral","score":0.1}', 'json');

INSERT INTO attachments (vcon_id, attachment_index, type, encoding, body) VALUES
('a0000008-0000-0000-0000-000000000008', 0, 'tags', 'json', '["branch:Nairobi","status:resolved","priority:low","channel:call","issue_category:billing"]'),
('a0000008-0000-0000-0000-000000000008', 1, 'consent', 'json', '{"consent_given":true,"consent_purpose":"customer support analysis","consent_law":"Kenya DPA","consent_granted_date":"2026-02-03","consent_expiry_date":"2026-04-04"}');

-- ============================================================
-- 9. Billing — Lagos (resolved SLOW, 2 days)
-- ============================================================

INSERT INTO vcons (id, uuid, vcon_version, subject, created_at, updated_at) VALUES
('a0000009-0000-0000-0000-000000000009', 'a0000009-0000-0000-0000-000000000009', '0.3.0',
 'Double billing on Lagos corporate account', NOW() - INTERVAL '5 days', NOW() - INTERVAL '3 days');

INSERT INTO parties (vcon_id, party_index, name, mailto, tel, metadata) VALUES
('a0000009-0000-0000-0000-000000000009', 0, 'Emeka Nwosu', 'emeka@techcorp.ng', NULL, '{"role":"agent"}'),
('a0000009-0000-0000-0000-000000000009', 1, 'Adebayo Ogundimu', 'adebayo@techcorp.ng', NULL, '{"role":"supervisor"}'),
('a0000009-0000-0000-0000-000000000009', 2, 'Folake Adeyinka', 'folake@enterprise.ng', NULL, '{"role":"customer"}');

INSERT INTO dialog (vcon_id, dialog_index, type, body, encoding, parties, start_time) VALUES
('a0000009-0000-0000-0000-000000000009', 0, 'text', 'We have been double-billed for three months now. This is unacceptable.', 'none', ARRAY[2], NOW() - INTERVAL '5 days'),
('a0000009-0000-0000-0000-000000000009', 1, 'text', 'I sincerely apologize. Let me investigate this with our billing department.', 'none', ARRAY[0], NOW() - INTERVAL '5 days' + INTERVAL '1 hour'),
('a0000009-0000-0000-0000-000000000009', 2, 'text', 'I have escalated to supervisor Adebayo as this requires finance team approval for the refund.', 'none', ARRAY[0], NOW() - INTERVAL '4 days'),
('a0000009-0000-0000-0000-000000000009', 3, 'text', 'We have identified the root cause. The refund for all three months has been processed and will arrive within 5 business days.', 'none', ARRAY[1], NOW() - INTERVAL '3 days');

INSERT INTO analysis (vcon_id, analysis_index, type, vendor, product, body, encoding) VALUES
('a0000009-0000-0000-0000-000000000009', 0, 'summary', 'TraceConnect', 'AI Analysis', 'Corporate customer double-billed for 3 months. Required supervisor escalation and finance approval. Resolved in 2 days.', 'none'),
('a0000009-0000-0000-0000-000000000009', 1, 'sentiment', 'TraceConnect', 'AI Analysis', '{"label":"negative","score":-0.4}', 'json');

INSERT INTO attachments (vcon_id, attachment_index, type, encoding, body) VALUES
('a0000009-0000-0000-0000-000000000009', 0, 'tags', 'json', '["branch:Lagos","status:resolved","priority:high","channel:email","issue_category:billing"]'),
('a0000009-0000-0000-0000-000000000009', 1, 'consent', 'json', '{"consent_given":true,"consent_purpose":"customer support analysis","consent_law":"Nigeria NDPR","consent_granted_date":"2025-12-05","consent_expiry_date":"2026-02-28"}');

-- ============================================================
-- 10. Billing — Lagos (resolved SLOW, 2 days) — EXPIRED CONSENT
-- ============================================================

INSERT INTO vcons (id, uuid, vcon_version, subject, created_at, updated_at) VALUES
('a0000010-0000-0000-0000-000000000010', 'a0000010-0000-0000-0000-000000000010', '0.3.0',
 'Incorrect VAT calculation on invoice', NOW() - INTERVAL '4 days', NOW() - INTERVAL '2 days');

INSERT INTO parties (vcon_id, party_index, name, mailto, tel, metadata) VALUES
('a0000010-0000-0000-0000-000000000010', 0, 'Chioma Okafor', 'chioma@techcorp.ng', NULL, '{"role":"agent"}'),
('a0000010-0000-0000-0000-000000000010', 1, 'Ibrahim Musa', 'ibrahim@business.ng', NULL, '{"role":"customer"}');

INSERT INTO dialog (vcon_id, dialog_index, type, body, encoding, parties, start_time) VALUES
('a0000010-0000-0000-0000-000000000010', 0, 'text', 'The VAT on my invoice is calculated at 10% but the current rate is 7.5%. Please correct this.', 'none', ARRAY[1], NOW() - INTERVAL '4 days'),
('a0000010-0000-0000-0000-000000000010', 1, 'text', 'Thank you for pointing this out. I need to check with our finance team on the correct tax configuration.', 'none', ARRAY[0], NOW() - INTERVAL '4 days' + INTERVAL '2 hours'),
('a0000010-0000-0000-0000-000000000010', 2, 'text', 'The finance team has updated the VAT rate. A corrected invoice has been sent to your email.', 'none', ARRAY[0], NOW() - INTERVAL '2 days');

INSERT INTO analysis (vcon_id, analysis_index, type, vendor, product, body, encoding) VALUES
('a0000010-0000-0000-0000-000000000010', 0, 'summary', 'TraceConnect', 'AI Analysis', 'VAT miscalculation on invoice. Required finance team involvement. Resolved in 2 days.', 'none'),
('a0000010-0000-0000-0000-000000000010', 1, 'sentiment', 'TraceConnect', 'AI Analysis', '{"label":"neutral","score":0.0}', 'json');

INSERT INTO attachments (vcon_id, attachment_index, type, encoding, body) VALUES
('a0000010-0000-0000-0000-000000000010', 0, 'tags', 'json', '["branch:Lagos","status:resolved","priority:medium","channel:email","issue_category:billing"]'),
('a0000010-0000-0000-0000-000000000010', 1, 'consent', 'json', '{"consent_given":true,"consent_purpose":"customer support analysis","consent_law":"Nigeria NDPR","consent_granted_date":"2025-12-10","consent_expiry_date":"2026-03-03"}');

-- ============================================================
-- 11. Full escalation trail — Lagos
-- ============================================================

INSERT INTO vcons (id, uuid, vcon_version, subject, created_at, updated_at) VALUES
('a0000011-0000-0000-0000-000000000011', 'a0000011-0000-0000-0000-000000000011', '0.3.0',
 'Complete service outage for enterprise client', NOW() - INTERVAL '3 days', NOW() - INTERVAL '2 days');

INSERT INTO parties (vcon_id, party_index, name, mailto, tel, metadata) VALUES
('a0000011-0000-0000-0000-000000000011', 0, 'Emeka Nwosu', 'emeka@techcorp.ng', NULL, '{"role":"agent"}'),
('a0000011-0000-0000-0000-000000000011', 1, 'Adebayo Ogundimu', 'adebayo@techcorp.ng', NULL, '{"role":"supervisor"}'),
('a0000011-0000-0000-0000-000000000011', 2, 'Chidi Obiora', 'chidi@megacorp.ng', NULL, '{"role":"customer"}');

INSERT INTO dialog (vcon_id, dialog_index, type, body, encoding, parties, start_time) VALUES
('a0000011-0000-0000-0000-000000000011', 0, 'text', 'Our entire network is down. We have 200 employees who cannot work. This is critical.', 'none', ARRAY[2], NOW() - INTERVAL '3 days'),
('a0000011-0000-0000-0000-000000000011', 1, 'text', 'I understand the severity. Let me check your service status immediately.', 'none', ARRAY[0], NOW() - INTERVAL '3 days' + INTERVAL '2 minutes'),
('a0000011-0000-0000-0000-000000000011', 2, 'text', 'I can see there is a routing issue on your dedicated line. Escalating to supervisor Adebayo now.', 'none', ARRAY[0], NOW() - INTERVAL '3 days' + INTERVAL '10 minutes'),
('a0000011-0000-0000-0000-000000000011', 3, 'text', 'Chidi, this is Adebayo. I have engaged our network operations team. They are working on restoring your service as the highest priority.', 'none', ARRAY[1], NOW() - INTERVAL '3 days' + INTERVAL '20 minutes'),
('a0000011-0000-0000-0000-000000000011', 4, 'text', 'Update: the routing issue has been identified and fixed. Your service should be restored within 15 minutes.', 'none', ARRAY[1], NOW() - INTERVAL '3 days' + INTERVAL '2 hours'),
('a0000011-0000-0000-0000-000000000011', 5, 'text', 'Service confirmed restored. We will provide a full incident report and SLA credit within 48 hours.', 'none', ARRAY[1], NOW() - INTERVAL '2 days');

INSERT INTO analysis (vcon_id, analysis_index, type, vendor, product, body, encoding) VALUES
('a0000011-0000-0000-0000-000000000011', 0, 'summary', 'TraceConnect', 'AI Analysis', 'Critical enterprise outage affecting 200 users. Escalated from agent Emeka to supervisor Adebayo. Network ops resolved routing issue. SLA credit being processed.', 'none'),
('a0000011-0000-0000-0000-000000000011', 1, 'sentiment', 'TraceConnect', 'AI Analysis', '{"label":"negative","score":-0.8}', 'json');

INSERT INTO attachments (vcon_id, attachment_index, type, encoding, body) VALUES
('a0000011-0000-0000-0000-000000000011', 0, 'tags', 'json', '["branch:Lagos","status:resolved","priority:high","channel:call","issue_category:service_outage"]'),
('a0000011-0000-0000-0000-000000000011', 1, 'consent', 'json', '{"consent_given":true,"consent_purpose":"customer support analysis","consent_law":"Nigeria NDPR","consent_granted_date":"2026-01-04","consent_expiry_date":"2026-03-06"}');

-- ============================================================
-- 12. New York — API rate limiting (resolved)
-- ============================================================

INSERT INTO vcons (id, uuid, vcon_version, subject, created_at, updated_at) VALUES
('a0000012-0000-0000-0000-000000000012', 'a0000012-0000-0000-0000-000000000012', '0.3.0',
 'API rate limiting affecting production app', NOW() - INTERVAL '2 days', NOW() - INTERVAL '1 day');

INSERT INTO parties (vcon_id, party_index, name, mailto, tel, metadata) VALUES
('a0000012-0000-0000-0000-000000000012', 0, 'Sarah Chen', 'sarah@techcorp.us', NULL, '{"role":"agent"}'),
('a0000012-0000-0000-0000-000000000012', 1, 'Mike Rodriguez', 'mike@startupco.com', NULL, '{"role":"customer"}');

INSERT INTO dialog (vcon_id, dialog_index, type, body, encoding, parties, start_time) VALUES
('a0000012-0000-0000-0000-000000000012', 0, 'text', 'Our production application is hitting rate limits on your API. We need the limit increased urgently.', 'none', ARRAY[1], NOW() - INTERVAL '2 days'),
('a0000012-0000-0000-0000-000000000012', 1, 'text', 'I can see your current tier allows 1000 requests per minute. Let me check your usage pattern.', 'none', ARRAY[0], NOW() - INTERVAL '2 days' + INTERVAL '15 minutes'),
('a0000012-0000-0000-0000-000000000012', 2, 'text', 'I have temporarily increased your limit to 5000 RPM and submitted a request to upgrade your tier.', 'none', ARRAY[0], NOW() - INTERVAL '1 day');

INSERT INTO analysis (vcon_id, analysis_index, type, vendor, product, body, encoding) VALUES
('a0000012-0000-0000-0000-000000000012', 0, 'summary', 'TraceConnect', 'AI Analysis', 'Production API rate limiting issue. Sarah provided temporary increase and initiated tier upgrade.', 'none'),
('a0000012-0000-0000-0000-000000000012', 1, 'sentiment', 'TraceConnect', 'AI Analysis', '{"label":"positive","score":0.4}', 'json');

INSERT INTO attachments (vcon_id, attachment_index, type, encoding, body) VALUES
('a0000012-0000-0000-0000-000000000012', 0, 'tags', 'json', '["branch:New York","status:resolved","priority:high","channel:chat","issue_category:technical"]'),
('a0000012-0000-0000-0000-000000000012', 1, 'consent', 'json', '{"consent_given":true,"consent_purpose":"customer support analysis","consent_law":"US TCPA","consent_granted_date":"2026-02-03","consent_expiry_date":"2026-05-04"}');

-- ============================================================
-- 13. New York — Feature request (open)
-- ============================================================

INSERT INTO vcons (id, uuid, vcon_version, subject, created_at, updated_at) VALUES
('a0000013-0000-0000-0000-000000000013', 'a0000013-0000-0000-0000-000000000013', '0.3.0',
 'Feature request: webhook retry mechanism', NOW() - INTERVAL '3 days', NOW() - INTERVAL '3 days');

INSERT INTO parties (vcon_id, party_index, name, mailto, tel, metadata) VALUES
('a0000013-0000-0000-0000-000000000013', 0, 'Michael Park', 'michael@techcorp.us', NULL, '{"role":"agent"}'),
('a0000013-0000-0000-0000-000000000013', 1, 'Lisa Wang', 'lisa@devshop.io', NULL, '{"role":"customer"}');

INSERT INTO dialog (vcon_id, dialog_index, type, body, encoding, parties, start_time) VALUES
('a0000013-0000-0000-0000-000000000013', 0, 'text', 'We keep losing webhook events when our server is briefly down. Do you have any retry mechanism?', 'none', ARRAY[1], NOW() - INTERVAL '3 days'),
('a0000013-0000-0000-0000-000000000013', 1, 'text', 'Currently we do not have automatic retries, but I can log this as a feature request. In the meantime, I recommend implementing a dead letter queue on your end.', 'none', ARRAY[0], NOW() - INTERVAL '3 days' + INTERVAL '30 minutes');

INSERT INTO analysis (vcon_id, analysis_index, type, vendor, product, body, encoding) VALUES
('a0000013-0000-0000-0000-000000000013', 0, 'summary', 'TraceConnect', 'AI Analysis', 'Customer requesting webhook retry mechanism. Logged as feature request. Agent suggested dead letter queue workaround.', 'none'),
('a0000013-0000-0000-0000-000000000013', 1, 'sentiment', 'TraceConnect', 'AI Analysis', '{"label":"neutral","score":0.1}', 'json');

INSERT INTO attachments (vcon_id, attachment_index, type, encoding, body) VALUES
('a0000013-0000-0000-0000-000000000013', 0, 'tags', 'json', '["branch:New York","status:open","priority:medium","channel:email","issue_category:feature_request"]'),
('a0000013-0000-0000-0000-000000000013', 1, 'consent', 'json', '{"consent_given":true,"consent_purpose":"customer support analysis","consent_law":"US TCPA","consent_granted_date":"2026-02-03","consent_expiry_date":"2026-05-04"}');

-- ============================================================
-- 14. New York — SSL cert (resolved, with supervisor)
-- ============================================================

INSERT INTO vcons (id, uuid, vcon_version, subject, created_at, updated_at) VALUES
('a0000014-0000-0000-0000-000000000014', 'a0000014-0000-0000-0000-000000000014', '0.3.0',
 'SSL certificate renewal failure', NOW() - INTERVAL '1 day', NOW() - INTERVAL '3 hours');

INSERT INTO parties (vcon_id, party_index, name, mailto, tel, metadata) VALUES
('a0000014-0000-0000-0000-000000000014', 0, 'David Kim', 'david@techcorp.us', NULL, '{"role":"agent"}'),
('a0000014-0000-0000-0000-000000000014', 1, 'Jennifer Liu', 'jennifer@techcorp.us', NULL, '{"role":"supervisor"}'),
('a0000014-0000-0000-0000-000000000014', 2, 'Tom Anderson', 'tom@bigretail.com', NULL, '{"role":"customer"}');

INSERT INTO dialog (vcon_id, dialog_index, type, body, encoding, parties, start_time) VALUES
('a0000014-0000-0000-0000-000000000014', 0, 'text', 'Our SSL certificate auto-renewal failed and now our customers are seeing security warnings. This is destroying our sales.', 'none', ARRAY[2], NOW() - INTERVAL '1 day'),
('a0000014-0000-0000-0000-000000000014', 1, 'text', 'This is urgent. Let me check the certificate status and renewal logs.', 'none', ARRAY[0], NOW() - INTERVAL '1 day' + INTERVAL '5 minutes'),
('a0000014-0000-0000-0000-000000000014', 2, 'text', 'The renewal failed due to a DNS validation issue. I am manually issuing a new certificate now.', 'none', ARRAY[0], NOW() - INTERVAL '1 day' + INTERVAL '30 minutes'),
('a0000014-0000-0000-0000-000000000014', 3, 'text', 'Tom, this is Jennifer. David has resolved the certificate issue. We are also implementing monitoring to prevent this from happening again.', 'none', ARRAY[1], NOW() - INTERVAL '3 hours');

INSERT INTO analysis (vcon_id, analysis_index, type, vendor, product, body, encoding) VALUES
('a0000014-0000-0000-0000-000000000014', 0, 'summary', 'TraceConnect', 'AI Analysis', 'SSL certificate renewal failure causing customer-facing security warnings. David resolved manually, Jennifer confirmed monitoring improvements.', 'none'),
('a0000014-0000-0000-0000-000000000014', 1, 'sentiment', 'TraceConnect', 'AI Analysis', '{"label":"positive","score":0.2}', 'json');

INSERT INTO attachments (vcon_id, attachment_index, type, encoding, body) VALUES
('a0000014-0000-0000-0000-000000000014', 0, 'tags', 'json', '["branch:New York","status:resolved","priority:high","channel:call","issue_category:technical"]'),
('a0000014-0000-0000-0000-000000000014', 1, 'consent', 'json', '{"consent_given":true,"consent_purpose":"quality monitoring","consent_law":"US TCPA","consent_granted_date":"2026-02-18","consent_expiry_date":"2026-05-19"}');

-- ============================================================
-- 15. Nairobi — Amina resolves account access (top performer)
-- ============================================================

INSERT INTO vcons (id, uuid, vcon_version, subject, created_at, updated_at) VALUES
('a0000015-0000-0000-0000-000000000015', 'a0000015-0000-0000-0000-000000000015', '0.3.0',
 'Account access recovery after password reset failure', NOW() - INTERVAL '2 days', NOW() - INTERVAL '2 days' + INTERVAL '30 minutes');

INSERT INTO parties (vcon_id, party_index, name, mailto, tel, metadata) VALUES
('a0000015-0000-0000-0000-000000000015', 0, 'Amina Wanjiku', 'amina@techcorp.ke', NULL, '{"role":"agent"}'),
('a0000015-0000-0000-0000-000000000015', 1, 'John Mwangi', 'john.m@gmail.com', NULL, '{"role":"customer"}');

INSERT INTO dialog (vcon_id, dialog_index, type, body, encoding, parties, start_time) VALUES
('a0000015-0000-0000-0000-000000000015', 0, 'text', 'I cannot reset my password. The reset email never arrives.', 'none', ARRAY[1], NOW() - INTERVAL '2 days'),
('a0000015-0000-0000-0000-000000000015', 1, 'text', 'Let me check your email configuration. It looks like your email provider is blocking our domain. I will send the reset from an alternate address.', 'none', ARRAY[0], NOW() - INTERVAL '2 days' + INTERVAL '10 minutes'),
('a0000015-0000-0000-0000-000000000015', 2, 'text', 'Reset email sent from our secondary domain. Please check your inbox now.', 'none', ARRAY[0], NOW() - INTERVAL '2 days' + INTERVAL '30 minutes');

INSERT INTO analysis (vcon_id, analysis_index, type, vendor, product, body, encoding) VALUES
('a0000015-0000-0000-0000-000000000015', 0, 'summary', 'TraceConnect', 'AI Analysis', 'Password reset emails blocked by customer email provider. Amina resolved by sending from alternate domain.', 'none'),
('a0000015-0000-0000-0000-000000000015', 1, 'sentiment', 'TraceConnect', 'AI Analysis', '{"label":"positive","score":0.8}', 'json');

INSERT INTO attachments (vcon_id, attachment_index, type, encoding, body) VALUES
('a0000015-0000-0000-0000-000000000015', 0, 'tags', 'json', '["branch:Nairobi","status:resolved","priority:medium","channel:chat","issue_category:account_access"]'),
('a0000015-0000-0000-0000-000000000015', 1, 'consent', 'json', '{"consent_given":true,"consent_purpose":"customer support analysis","consent_law":"Kenya DPA","consent_granted_date":"2026-02-13","consent_expiry_date":"2026-04-14"}');

-- ============================================================
-- 16. Nairobi — Amina resolves data export (top performer)
-- ============================================================

INSERT INTO vcons (id, uuid, vcon_version, subject, created_at, updated_at) VALUES
('a0000016-0000-0000-0000-000000000016', 'a0000016-0000-0000-0000-000000000016', '0.3.0',
 'Data export request for compliance audit', NOW() - INTERVAL '1 day', NOW() - INTERVAL '2 hours');

INSERT INTO parties (vcon_id, party_index, name, mailto, tel, metadata) VALUES
('a0000016-0000-0000-0000-000000000016', 0, 'Amina Wanjiku', 'amina@techcorp.ke', NULL, '{"role":"agent"}'),
('a0000016-0000-0000-0000-000000000016', 1, 'Supervisor Kamau', 'kamau@techcorp.ke', NULL, '{"role":"supervisor"}'),
('a0000016-0000-0000-0000-000000000016', 2, 'Rebecca Njoroge', 'rebecca@auditfirm.co.ke', NULL, '{"role":"customer"}');

INSERT INTO dialog (vcon_id, dialog_index, type, body, encoding, parties, start_time) VALUES
('a0000016-0000-0000-0000-000000000016', 0, 'text', 'We need a full data export for our annual compliance audit. Can this be done within 48 hours?', 'none', ARRAY[2], NOW() - INTERVAL '1 day'),
('a0000016-0000-0000-0000-000000000016', 1, 'text', 'Absolutely. I will prepare the export and have supervisor Kamau verify it before sending.', 'none', ARRAY[0], NOW() - INTERVAL '1 day' + INTERVAL '15 minutes'),
('a0000016-0000-0000-0000-000000000016', 2, 'text', 'Export verified and sent to your secure portal. All data is included as requested.', 'none', ARRAY[1], NOW() - INTERVAL '2 hours');

INSERT INTO analysis (vcon_id, analysis_index, type, vendor, product, body, encoding) VALUES
('a0000016-0000-0000-0000-000000000016', 0, 'summary', 'TraceConnect', 'AI Analysis', 'Compliance audit data export requested. Amina prepared export, supervisor Kamau verified. Delivered within SLA.', 'none'),
('a0000016-0000-0000-0000-000000000016', 1, 'sentiment', 'TraceConnect', 'AI Analysis', '{"label":"positive","score":0.9}', 'json');

INSERT INTO attachments (vcon_id, attachment_index, type, encoding, body) VALUES
('a0000016-0000-0000-0000-000000000016', 0, 'tags', 'json', '["branch:Nairobi","status:resolved","priority:medium","channel:email","issue_category:data_request"]'),
('a0000016-0000-0000-0000-000000000016', 1, 'consent', 'json', '{"consent_given":true,"consent_purpose":"customer support analysis","consent_law":"Kenya DPA","consent_granted_date":"2026-02-28","consent_expiry_date":"2026-04-29"}');

-- ============================================================
-- 17. Lagos — No consent given
-- ============================================================

INSERT INTO vcons (id, uuid, vcon_version, subject, created_at, updated_at) VALUES
('a0000017-0000-0000-0000-000000000017', 'a0000017-0000-0000-0000-000000000017', '0.3.0',
 'Network latency issues during peak hours', NOW() - INTERVAL '6 days', NOW() - INTERVAL '5 days');

INSERT INTO parties (vcon_id, party_index, name, mailto, tel, metadata) VALUES
('a0000017-0000-0000-0000-000000000017', 0, 'Ngozi Eze', 'ngozi@techcorp.ng', NULL, '{"role":"agent"}'),
('a0000017-0000-0000-0000-000000000017', 1, 'Yusuf Bello', NULL, '+234-805-555-0404', '{"role":"customer"}');

INSERT INTO dialog (vcon_id, dialog_index, type, body, encoding, parties, start_time) VALUES
('a0000017-0000-0000-0000-000000000017', 0, 'text', 'Every day between 2pm and 5pm our internet becomes unusable. This has been going on for two weeks.', 'none', ARRAY[1], NOW() - INTERVAL '6 days'),
('a0000017-0000-0000-0000-000000000017', 1, 'text', 'I will run diagnostics on your connection during those hours and get back to you with findings.', 'none', ARRAY[0], NOW() - INTERVAL '6 days' + INTERVAL '10 minutes');

INSERT INTO analysis (vcon_id, analysis_index, type, vendor, product, body, encoding) VALUES
('a0000017-0000-0000-0000-000000000017', 0, 'summary', 'TraceConnect', 'AI Analysis', 'Recurring peak-hour latency issues. Agent running diagnostics.', 'none'),
('a0000017-0000-0000-0000-000000000017', 1, 'sentiment', 'TraceConnect', 'AI Analysis', '{"label":"negative","score":-0.3}', 'json');

INSERT INTO attachments (vcon_id, attachment_index, type, encoding, body) VALUES
('a0000017-0000-0000-0000-000000000017', 0, 'tags', 'json', '["branch:Lagos","status:open","priority:medium","channel:call","issue_category:network"]'),
('a0000017-0000-0000-0000-000000000017', 1, 'consent', 'json', '{"consent_given":false,"consent_purpose":"customer support analysis","consent_law":"Nigeria NDPR"}');

-- ============================================================
-- 18. New York — Salesforce integration (in progress)
-- ============================================================

INSERT INTO vcons (id, uuid, vcon_version, subject, created_at, updated_at) VALUES
('a0000018-0000-0000-0000-000000000018', 'a0000018-0000-0000-0000-000000000018', '0.3.0',
 'Integration with Salesforce CRM not syncing', NOW() - INTERVAL '1 day', NOW() - INTERVAL '1 day');

INSERT INTO parties (vcon_id, party_index, name, mailto, tel, metadata) VALUES
('a0000018-0000-0000-0000-000000000018', 0, 'Sarah Chen', 'sarah@techcorp.us', NULL, '{"role":"agent"}'),
('a0000018-0000-0000-0000-000000000018', 1, 'James Foster', 'james@consulting.com', NULL, '{"role":"customer"}');

INSERT INTO dialog (vcon_id, dialog_index, type, body, encoding, parties, start_time) VALUES
('a0000018-0000-0000-0000-000000000018', 0, 'text', 'Our Salesforce integration stopped syncing contacts two days ago. We are missing critical customer data.', 'none', ARRAY[1], NOW() - INTERVAL '1 day'),
('a0000018-0000-0000-0000-000000000018', 1, 'text', 'I can see the sync error in our logs. It appears your Salesforce API token expired. Let me guide you through re-authentication.', 'none', ARRAY[0], NOW() - INTERVAL '1 day' + INTERVAL '20 minutes');

INSERT INTO analysis (vcon_id, analysis_index, type, vendor, product, body, encoding) VALUES
('a0000018-0000-0000-0000-000000000018', 0, 'summary', 'TraceConnect', 'AI Analysis', 'Salesforce CRM integration sync failure due to expired API token. Agent guiding re-authentication.', 'none'),
('a0000018-0000-0000-0000-000000000018', 1, 'sentiment', 'TraceConnect', 'AI Analysis', '{"label":"negative","score":-0.2}', 'json');

INSERT INTO attachments (vcon_id, attachment_index, type, encoding, body) VALUES
('a0000018-0000-0000-0000-000000000018', 0, 'tags', 'json', '["branch:New York","status:in_progress","priority:high","channel:email","issue_category:integration"]'),
('a0000018-0000-0000-0000-000000000018', 1, 'consent', 'json', '{"consent_given":true,"consent_purpose":"customer support analysis","consent_law":"US TCPA","consent_granted_date":"2026-01-19","consent_expiry_date":"2026-04-19"}');

-- Refresh the materialized view for tags
SELECT refresh_vcon_tags_mv();
