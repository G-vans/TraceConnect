// Seed script for TraceConnect — inserts 18 conversations across 3 branches.
// Run: node scripts/seed_conversations.mjs

import { createClient } from '@supabase/supabase-js';
import { randomUUID } from 'crypto';

const supabase = createClient(
  'https://aufoguugseioihxvtjpa.supabase.co',
  'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImF1Zm9ndXVnc2Vpb2loeHZ0anBhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzI2OTgxODcsImV4cCI6MjA4ODI3NDE4N30.rnP6-OqNWvRc6aL8INn_lsRfyFVWnCSZA8RHO15D7mU'
);

// Helper: days ago from now
function daysAgo(d) {
  const date = new Date();
  date.setDate(date.getDate() - d);
  return date.toISOString();
}

function hoursAgo(h) {
  const date = new Date();
  date.setHours(date.getHours() - h);
  return date.toISOString();
}

function daysFromNow(d) {
  const date = new Date();
  date.setDate(date.getDate() + d);
  return date.toISOString().split('T')[0];
}

function daysAgoDate(d) {
  const date = new Date();
  date.setDate(date.getDate() - d);
  return date.toISOString().split('T')[0];
}

async function createVcon(conv) {
  // 1. Insert vcon
  const { data: vcon, error: vconErr } = await supabase
    .from('vcons')
    .insert({
      uuid: randomUUID(),
      vcon_version: '0.3.0',
      subject: conv.subject,
      created_at: conv.created_at,
      updated_at: conv.updated_at || conv.created_at
    })
    .select('id, uuid')
    .single();

  if (vconErr) { console.error('vcon error:', conv.subject, vconErr.message); return; }

  // 2. Insert parties
  const parties = conv.parties.map((p, i) => ({
    vcon_id: vcon.id,
    party_index: i,
    name: p.name,
    mailto: p.mailto || null,
    tel: p.tel || null,
    metadata: { role: p.role }
  }));
  const { error: partyErr } = await supabase.from('parties').insert(parties);
  if (partyErr) console.error('party error:', conv.subject, partyErr.message);

  // 3. Insert dialog
  const dialogs = conv.dialogs.map((d, i) => ({
    vcon_id: vcon.id,
    dialog_index: i,
    type: 'text',
    body: d.body,
    encoding: 'none',
    parties: d.parties,
    start_time: d.start_time
  }));
  const { error: dialogErr } = await supabase.from('dialog').insert(dialogs);
  if (dialogErr) console.error('dialog error:', conv.subject, dialogErr.message);

  // 4. Insert analysis (summary + sentiment)
  const analyses = [];
  if (conv.summary) {
    analyses.push({
      vcon_id: vcon.id,
      analysis_index: 0,
      type: 'summary',
      vendor: 'TraceConnect',
      product: 'AI Analysis',
      body: conv.summary,
      encoding: 'none'
    });
  }
  if (conv.sentiment) {
    analyses.push({
      vcon_id: vcon.id,
      analysis_index: analyses.length,
      type: 'sentiment',
      vendor: 'TraceConnect',
      product: 'AI Analysis',
      body: JSON.stringify(conv.sentiment),
      encoding: 'json'
    });
  }
  if (analyses.length) {
    const { error: analysisErr } = await supabase.from('analysis').insert(analyses);
    if (analysisErr) console.error('analysis error:', conv.subject, analysisErr.message);
  }

  // 5. Insert tags attachment
  let attachmentIndex = 0;
  const { error: tagErr } = await supabase.from('attachments').insert({
    vcon_id: vcon.id,
    attachment_index: attachmentIndex++,
    type: 'tags',
    encoding: 'json',
    body: JSON.stringify(conv.tags)
  });
  if (tagErr) console.error('tags error:', conv.subject, tagErr.message);

  // 6. Insert consent attachment
  if (conv.consent) {
    const { error: consentErr } = await supabase.from('attachments').insert({
      vcon_id: vcon.id,
      attachment_index: attachmentIndex++,
      type: 'consent',
      encoding: 'json',
      body: JSON.stringify(conv.consent)
    });
    if (consentErr) console.error('consent error:', conv.subject, consentErr.message);
  }

  console.log(`  ✓ ${conv.subject} [${conv.tags.find(t => t.startsWith('branch:'))?.split(':')[1]}]`);
}

// ============================================================
// SEED DATA — 18 conversations across 3 branches
// ============================================================

const conversations = [

  // ── PATTERN DETECTION: SmartRouter Pro overheating (Lagos Mon-Tue, Nairobi Wed) ──

  {
    subject: 'SmartRouter Pro overheating after firmware update',
    created_at: daysAgo(4),
    updated_at: daysAgo(4),
    parties: [
      { name: 'Chioma Okafor', role: 'agent', mailto: 'chioma@techcorp.ng' },
      { name: 'Kunle Adeyemi', role: 'customer', tel: '+234-801-555-0101' }
    ],
    dialogs: [
      { body: 'Good morning, my SmartRouter Pro has been overheating since the latest firmware update. It shuts down after 30 minutes.', parties: [1], start_time: daysAgo(4) },
      { body: 'I understand your concern. Can you confirm the firmware version? We have received similar reports.', parties: [0], start_time: daysAgo(4) },
      { body: 'Version 3.2.1, installed two days ago.', parties: [1], start_time: daysAgo(4) },
      { body: 'Thank you. I am escalating this to our product team. Please roll back to version 3.1.8 for now.', parties: [0], start_time: daysAgo(4) }
    ],
    tags: ['branch:Lagos', 'status:open', 'priority:high', 'channel:call', 'issue_category:product_defect'],
    summary: 'Customer reports SmartRouter Pro overheating after firmware 3.2.1 update. Agent advised rollback to 3.1.8 and escalated to product team.',
    sentiment: { label: 'negative', score: -0.6 },
    consent: { consent_given: true, consent_purpose: 'customer support analysis', consent_law: 'Nigeria NDPR', consent_granted_date: daysAgoDate(30), consent_expiry_date: daysFromNow(30) }
  },

  {
    subject: 'SmartRouter Pro shutting down due to heat',
    created_at: daysAgo(3),
    updated_at: daysAgo(3),
    parties: [
      { name: 'Emeka Nwosu', role: 'agent', mailto: 'emeka@techcorp.ng' },
      { name: 'Blessing Igwe', role: 'customer', tel: '+234-802-555-0202' }
    ],
    dialogs: [
      { body: 'My SmartRouter Pro keeps shutting down. I think it is overheating. This started after an automatic update.', parties: [1], start_time: daysAgo(3) },
      { body: 'Yes, we are aware of this issue with firmware 3.2.1. I will help you roll back immediately.', parties: [0], start_time: daysAgo(3) }
    ],
    tags: ['branch:Lagos', 'status:in_progress', 'priority:high', 'channel:call', 'issue_category:product_defect'],
    summary: 'Second report of SmartRouter Pro overheating in Lagos. Agent confirmed known firmware issue and initiated rollback.',
    sentiment: { label: 'negative', score: -0.5 },
    consent: { consent_given: true, consent_purpose: 'customer support analysis', consent_law: 'Nigeria NDPR', consent_granted_date: daysAgoDate(25), consent_expiry_date: daysFromNow(35) }
  },

  {
    subject: 'SmartRouter Pro thermal warning — third report',
    created_at: daysAgo(3),
    updated_at: daysAgo(2),
    parties: [
      { name: 'Ngozi Eze', role: 'agent', mailto: 'ngozi@techcorp.ng' },
      { name: 'Adebayo Ogundimu', role: 'supervisor', mailto: 'adebayo@techcorp.ng' },
      { name: 'Tunde Bakare', role: 'customer', tel: '+234-803-555-0303' }
    ],
    dialogs: [
      { body: 'I bought the SmartRouter Pro last month and it is now showing a thermal warning light constantly.', parties: [2], start_time: daysAgo(3) },
      { body: 'This is the third report we have received about this. I am escalating to supervisor Adebayo.', parties: [0], start_time: daysAgo(3) },
      { body: 'Thank you Ngozi. Customer, we are treating this as a priority. Our product team is investigating the firmware update that caused this issue. We will contact you within 24 hours with a resolution.', parties: [1], start_time: daysAgo(2) }
    ],
    tags: ['branch:Lagos', 'status:in_progress', 'priority:high', 'channel:call', 'issue_category:product_defect'],
    summary: 'Third SmartRouter Pro overheating report in Lagos. Escalated to supervisor Adebayo. Product team investigating firmware 3.2.1.',
    sentiment: { label: 'negative', score: -0.7 },
    consent: { consent_given: true, consent_purpose: 'customer support analysis', consent_law: 'Nigeria NDPR', consent_granted_date: daysAgoDate(20), consent_expiry_date: daysFromNow(40) }
  },

  {
    subject: 'SmartRouter Pro overheating — same as Lagos reports',
    created_at: daysAgo(2),
    updated_at: daysAgo(1),
    parties: [
      { name: 'Amina Wanjiku', role: 'agent', mailto: 'amina@techcorp.ke' },
      { name: 'Peter Kamau', role: 'customer', tel: '+254-722-555-0101' }
    ],
    dialogs: [
      { body: 'My SmartRouter Pro is overheating badly. I saw online that others in Nigeria are having the same problem.', parties: [1], start_time: daysAgo(2) },
      { body: 'Thank you for letting us know. We are aware of this issue affecting the latest firmware. I will apply the fix immediately.', parties: [0], start_time: daysAgo(2) },
      { body: 'The rollback is complete. Please monitor and let us know if the issue persists.', parties: [0], start_time: daysAgo(1) }
    ],
    tags: ['branch:Nairobi', 'status:resolved', 'priority:high', 'channel:call', 'issue_category:product_defect'],
    summary: 'SmartRouter Pro overheating reported in Nairobi — same firmware 3.2.1 issue as Lagos. Agent Amina resolved with rollback in 1 hour.',
    sentiment: { label: 'positive', score: 0.3 },
    consent: { consent_given: true, consent_purpose: 'customer support analysis', consent_law: 'Kenya DPA', consent_granted_date: daysAgoDate(15), consent_expiry_date: daysFromNow(45) }
  },

  {
    subject: 'SmartRouter Pro heat issue after update',
    created_at: daysAgo(1),
    updated_at: hoursAgo(6),
    parties: [
      { name: 'Joseph Ochieng', role: 'agent', mailto: 'joseph@techcorp.ke' },
      { name: 'Grace Muthoni', role: 'customer', tel: '+254-733-555-0202' }
    ],
    dialogs: [
      { body: 'Hello, my router started overheating yesterday. Is there a known issue?', parties: [1], start_time: daysAgo(1) },
      { body: 'Yes, we have identified a firmware issue. Let me fix this for you right away.', parties: [0], start_time: daysAgo(1) },
      { body: 'Done. Your router has been rolled back to a stable version. You should be good now.', parties: [0], start_time: hoursAgo(6) }
    ],
    tags: ['branch:Nairobi', 'status:resolved', 'priority:high', 'channel:chat', 'issue_category:product_defect'],
    summary: 'Fifth SmartRouter Pro overheating report, second in Nairobi. Joseph resolved quickly via chat.',
    sentiment: { label: 'positive', score: 0.5 },
    consent: { consent_given: true, consent_purpose: 'customer support analysis', consent_law: 'Kenya DPA', consent_granted_date: daysAgoDate(10), consent_expiry_date: daysFromNow(50) }
  },

  // ── PERFORMANCE COMPARISON: Billing complaints (Nairobi fast, Lagos slow) ──

  {
    subject: 'Incorrect charge on monthly invoice',
    created_at: daysAgo(5),
    updated_at: daysAgo(5),
    parties: [
      { name: 'Amina Wanjiku', role: 'agent', mailto: 'amina@techcorp.ke' },
      { name: 'Daniel Kiprop', role: 'customer', mailto: 'daniel.k@email.com' }
    ],
    dialogs: [
      { body: 'I have been charged twice for my subscription this month. Can you fix this?', parties: [1], start_time: daysAgo(5) },
      { body: 'I can see the duplicate charge. Let me process a refund right away. It will reflect in 24 hours.', parties: [0], start_time: daysAgo(5) },
      { body: 'Refund processed. Is there anything else I can help with?', parties: [0], start_time: daysAgo(5) }
    ],
    tags: ['branch:Nairobi', 'status:resolved', 'priority:medium', 'channel:email', 'issue_category:billing'],
    summary: 'Customer reported duplicate charge. Agent Amina resolved with immediate refund within 2 hours.',
    sentiment: { label: 'positive', score: 0.7 },
    consent: { consent_given: true, consent_purpose: 'customer support analysis', consent_law: 'Kenya DPA', consent_granted_date: daysAgoDate(60), consent_expiry_date: daysFromNow(1) }
  },

  {
    subject: 'Billing discrepancy on enterprise plan',
    created_at: daysAgo(4),
    updated_at: daysAgo(4),
    parties: [
      { name: 'Wanjiku Njeri', role: 'agent', mailto: 'wanjiku@techcorp.ke' },
      { name: 'Samuel Otieno', role: 'customer', mailto: 'samuel.o@company.co.ke' }
    ],
    dialogs: [
      { body: 'Our company was charged for 50 licenses but we only have 35 active users.', parties: [1], start_time: daysAgo(4) },
      { body: 'I see the discrepancy. It looks like inactive users were not removed during the last audit. I will correct this and issue a credit note.', parties: [0], start_time: daysAgo(4) },
      { body: 'Credit note issued for the difference. Your next invoice will reflect the correct count.', parties: [0], start_time: daysAgo(4) }
    ],
    tags: ['branch:Nairobi', 'status:resolved', 'priority:medium', 'channel:email', 'issue_category:billing'],
    summary: 'Enterprise customer overcharged for inactive licenses. Wanjiku resolved same day with credit note.',
    sentiment: { label: 'positive', score: 0.6 },
    consent: { consent_given: true, consent_purpose: 'customer support analysis', consent_law: 'Kenya DPA', consent_granted_date: daysAgoDate(45), consent_expiry_date: daysFromNow(15) }
  },

  {
    subject: 'Unexpected pro-rata charges on upgrade',
    created_at: daysAgo(6),
    updated_at: daysAgo(6),
    parties: [
      { name: 'Ochieng Odongo', role: 'agent', mailto: 'ochieng@techcorp.ke' },
      { name: 'Mary Wambui', role: 'customer', tel: '+254-710-555-0303' }
    ],
    dialogs: [
      { body: 'I upgraded my plan last week but I was charged the full amount instead of the pro-rata difference.', parties: [1], start_time: daysAgo(6) },
      { body: 'Let me check your account. Yes, the pro-rata calculation was not applied correctly. I will fix this now.', parties: [0], start_time: daysAgo(6) }
    ],
    tags: ['branch:Nairobi', 'status:resolved', 'priority:low', 'channel:call', 'issue_category:billing'],
    summary: 'Pro-rata billing error on plan upgrade. Agent Ochieng corrected the charge within 1 hour.',
    sentiment: { label: 'neutral', score: 0.1 },
    consent: { consent_given: true, consent_purpose: 'customer support analysis', consent_law: 'Kenya DPA', consent_granted_date: daysAgoDate(30), consent_expiry_date: daysFromNow(30) }
  },

  {
    subject: 'Double billing on Lagos corporate account',
    created_at: daysAgo(5),
    updated_at: daysAgo(3),
    parties: [
      { name: 'Emeka Nwosu', role: 'agent', mailto: 'emeka@techcorp.ng' },
      { name: 'Adebayo Ogundimu', role: 'supervisor', mailto: 'adebayo@techcorp.ng' },
      { name: 'Folake Adeyinka', role: 'customer', mailto: 'folake@enterprise.ng' }
    ],
    dialogs: [
      { body: 'We have been double-billed for three months now. This is unacceptable.', parties: [2], start_time: daysAgo(5) },
      { body: 'I sincerely apologize. Let me investigate this with our billing department.', parties: [0], start_time: daysAgo(5) },
      { body: 'I have escalated to supervisor Adebayo as this requires finance team approval for the refund.', parties: [0], start_time: daysAgo(4) },
      { body: 'We have identified the root cause. The refund for all three months has been processed and will arrive within 5 business days.', parties: [1], start_time: daysAgo(3) }
    ],
    tags: ['branch:Lagos', 'status:resolved', 'priority:high', 'channel:email', 'issue_category:billing'],
    summary: 'Corporate customer double-billed for 3 months. Required supervisor escalation and finance approval. Resolved in 2 days.',
    sentiment: { label: 'negative', score: -0.4 },
    consent: { consent_given: true, consent_purpose: 'customer support analysis', consent_law: 'Nigeria NDPR', consent_granted_date: daysAgoDate(90), consent_expiry_date: daysAgoDate(5) }
  },

  {
    subject: 'Incorrect VAT calculation on invoice',
    created_at: daysAgo(4),
    updated_at: daysAgo(2),
    parties: [
      { name: 'Chioma Okafor', role: 'agent', mailto: 'chioma@techcorp.ng' },
      { name: 'Ibrahim Musa', role: 'customer', mailto: 'ibrahim@business.ng' }
    ],
    dialogs: [
      { body: 'The VAT on my invoice is calculated at 10% but the current rate is 7.5%. Please correct this.', parties: [1], start_time: daysAgo(4) },
      { body: 'Thank you for pointing this out. I need to check with our finance team on the correct tax configuration.', parties: [0], start_time: daysAgo(4) },
      { body: 'The finance team has updated the VAT rate. A corrected invoice has been sent to your email.', parties: [0], start_time: daysAgo(2) }
    ],
    tags: ['branch:Lagos', 'status:resolved', 'priority:medium', 'channel:email', 'issue_category:billing'],
    summary: 'VAT miscalculation on invoice. Required finance team involvement. Resolved in 2 days.',
    sentiment: { label: 'neutral', score: 0.0 },
    consent: { consent_given: true, consent_purpose: 'customer support analysis', consent_law: 'Nigeria NDPR', consent_granted_date: daysAgoDate(80), consent_expiry_date: daysAgoDate(2) }
  },

  // ── CONVERSATION TRAIL SET: Full escalation trail in Lagos ──

  {
    subject: 'Complete service outage for enterprise client',
    created_at: daysAgo(3),
    updated_at: daysAgo(2),
    parties: [
      { name: 'Emeka Nwosu', role: 'agent', mailto: 'emeka@techcorp.ng' },
      { name: 'Adebayo Ogundimu', role: 'supervisor', mailto: 'adebayo@techcorp.ng' },
      { name: 'Chidi Obiora', role: 'customer', mailto: 'chidi@megacorp.ng' }
    ],
    dialogs: [
      { body: 'Our entire network is down. We have 200 employees who cannot work. This is critical.', parties: [2], start_time: daysAgo(3) },
      { body: 'I understand the severity. Let me check your service status immediately.', parties: [0], start_time: daysAgo(3) },
      { body: 'I can see there is a routing issue on your dedicated line. Escalating to supervisor Adebayo now.', parties: [0], start_time: daysAgo(3) },
      { body: 'Chidi, this is Adebayo. I have engaged our network operations team. They are working on restoring your service as the highest priority.', parties: [1], start_time: daysAgo(3) },
      { body: 'Update: the routing issue has been identified and fixed. Your service should be restored within 15 minutes.', parties: [1], start_time: daysAgo(3) },
      { body: 'Service confirmed restored. We will provide a full incident report and SLA credit within 48 hours.', parties: [1], start_time: daysAgo(2) }
    ],
    tags: ['branch:Lagos', 'status:resolved', 'priority:high', 'channel:call', 'issue_category:service_outage'],
    summary: 'Critical enterprise outage affecting 200 users. Escalated from agent Emeka to supervisor Adebayo. Network ops resolved routing issue. SLA credit being processed.',
    sentiment: { label: 'negative', score: -0.8 },
    consent: { consent_given: true, consent_purpose: 'customer support analysis', consent_law: 'Nigeria NDPR', consent_granted_date: daysAgoDate(60), consent_expiry_date: daysFromNow(1) }
  },

  // ── NEW YORK conversations ──

  {
    subject: 'API rate limiting affecting production app',
    created_at: daysAgo(2),
    updated_at: daysAgo(1),
    parties: [
      { name: 'Sarah Chen', role: 'agent', mailto: 'sarah@techcorp.us' },
      { name: 'Mike Rodriguez', role: 'customer', mailto: 'mike@startupco.com' }
    ],
    dialogs: [
      { body: 'Our production application is hitting rate limits on your API. We need the limit increased urgently.', parties: [1], start_time: daysAgo(2) },
      { body: 'I can see your current tier allows 1000 requests per minute. Let me check your usage pattern and see what we can do.', parties: [0], start_time: daysAgo(2) },
      { body: 'I have temporarily increased your limit to 5000 RPM and submitted a request to upgrade your tier. You should be unblocked now.', parties: [0], start_time: daysAgo(1) }
    ],
    tags: ['branch:New York', 'status:resolved', 'priority:high', 'channel:chat', 'issue_category:technical'],
    summary: 'Production API rate limiting issue. Sarah provided temporary increase and initiated tier upgrade.',
    sentiment: { label: 'positive', score: 0.4 },
    consent: { consent_given: true, consent_purpose: 'customer support analysis', consent_law: 'US TCPA', consent_granted_date: daysAgoDate(30), consent_expiry_date: daysFromNow(60) }
  },

  {
    subject: 'Feature request: webhook retry mechanism',
    created_at: daysAgo(3),
    parties: [
      { name: 'Michael Park', role: 'agent', mailto: 'michael@techcorp.us' },
      { name: 'Lisa Wang', role: 'customer', mailto: 'lisa@devshop.io' }
    ],
    dialogs: [
      { body: 'We keep losing webhook events when our server is briefly down. Do you have any retry mechanism?', parties: [1], start_time: daysAgo(3) },
      { body: 'Currently we do not have automatic retries, but I can log this as a feature request. In the meantime, I recommend implementing a dead letter queue on your end.', parties: [0], start_time: daysAgo(3) }
    ],
    tags: ['branch:New York', 'status:open', 'priority:medium', 'channel:email', 'issue_category:feature_request'],
    summary: 'Customer requesting webhook retry mechanism. Logged as feature request. Agent suggested dead letter queue workaround.',
    sentiment: { label: 'neutral', score: 0.1 },
    consent: { consent_given: true, consent_purpose: 'customer support analysis', consent_law: 'US TCPA', consent_granted_date: daysAgoDate(30), consent_expiry_date: daysFromNow(60) }
  },

  {
    subject: 'SSL certificate renewal failure',
    created_at: daysAgo(1),
    updated_at: hoursAgo(3),
    parties: [
      { name: 'David Kim', role: 'agent', mailto: 'david@techcorp.us' },
      { name: 'Jennifer Liu', role: 'supervisor', mailto: 'jennifer@techcorp.us' },
      { name: 'Tom Anderson', role: 'customer', mailto: 'tom@bigretail.com' }
    ],
    dialogs: [
      { body: 'Our SSL certificate auto-renewal failed and now our customers are seeing security warnings. This is destroying our sales.', parties: [2], start_time: daysAgo(1) },
      { body: 'This is urgent. Let me check the certificate status and renewal logs.', parties: [0], start_time: daysAgo(1) },
      { body: 'The renewal failed due to a DNS validation issue. I am manually issuing a new certificate now.', parties: [0], start_time: daysAgo(1) },
      { body: 'Tom, this is Jennifer from the supervisor team. David has resolved the certificate issue. We are also implementing monitoring to prevent this from happening again.', parties: [1], start_time: hoursAgo(3) }
    ],
    tags: ['branch:New York', 'status:resolved', 'priority:high', 'channel:call', 'issue_category:technical'],
    summary: 'SSL certificate renewal failure causing customer-facing security warnings. David resolved manually, Jennifer confirmed monitoring improvements.',
    sentiment: { label: 'positive', score: 0.2 },
    consent: { consent_given: true, consent_purpose: 'quality monitoring', consent_law: 'US TCPA', consent_granted_date: daysAgoDate(15), consent_expiry_date: daysFromNow(75) }
  },

  // ── TOP PERFORMER: Amina with extra resolved issues ──

  {
    subject: 'Account access recovery after password reset failure',
    created_at: daysAgo(2),
    updated_at: daysAgo(2),
    parties: [
      { name: 'Amina Wanjiku', role: 'agent', mailto: 'amina@techcorp.ke' },
      { name: 'John Mwangi', role: 'customer', mailto: 'john.m@gmail.com' }
    ],
    dialogs: [
      { body: 'I cannot reset my password. The reset email never arrives.', parties: [1], start_time: daysAgo(2) },
      { body: 'Let me check your email configuration. It looks like your email provider is blocking our domain. I will send the reset from an alternate address.', parties: [0], start_time: daysAgo(2) },
      { body: 'Reset email sent from our secondary domain. Please check your inbox now.', parties: [0], start_time: daysAgo(2) }
    ],
    tags: ['branch:Nairobi', 'status:resolved', 'priority:medium', 'channel:chat', 'issue_category:account_access'],
    summary: 'Password reset emails blocked by customer email provider. Amina resolved by sending from alternate domain.',
    sentiment: { label: 'positive', score: 0.8 },
    consent: { consent_given: true, consent_purpose: 'customer support analysis', consent_law: 'Kenya DPA', consent_granted_date: daysAgoDate(20), consent_expiry_date: daysFromNow(40) }
  },

  {
    subject: 'Data export request for compliance audit',
    created_at: daysAgo(1),
    updated_at: hoursAgo(2),
    parties: [
      { name: 'Amina Wanjiku', role: 'agent', mailto: 'amina@techcorp.ke' },
      { name: 'Supervisor Kamau', role: 'supervisor', mailto: 'kamau@techcorp.ke' },
      { name: 'Rebecca Njoroge', role: 'customer', mailto: 'rebecca@auditfirm.co.ke' }
    ],
    dialogs: [
      { body: 'We need a full data export for our annual compliance audit. Can this be done within 48 hours?', parties: [2], start_time: daysAgo(1) },
      { body: 'Absolutely. I will prepare the export and have supervisor Kamau verify it before sending.', parties: [0], start_time: daysAgo(1) },
      { body: 'Export verified and sent to your secure portal. All data is included as requested.', parties: [1], start_time: hoursAgo(2) }
    ],
    tags: ['branch:Nairobi', 'status:resolved', 'priority:medium', 'channel:email', 'issue_category:data_request'],
    summary: 'Compliance audit data export requested. Amina prepared export, supervisor Kamau verified. Delivered within SLA.',
    sentiment: { label: 'positive', score: 0.9 },
    consent: { consent_given: true, consent_purpose: 'customer support analysis', consent_law: 'Kenya DPA', consent_granted_date: daysAgoDate(5), consent_expiry_date: daysFromNow(55) }
  },

  // ── CONSENT SCENARIOS: Expired consent in Lagos ──

  {
    subject: 'Network latency issues during peak hours',
    created_at: daysAgo(6),
    updated_at: daysAgo(5),
    parties: [
      { name: 'Ngozi Eze', role: 'agent', mailto: 'ngozi@techcorp.ng' },
      { name: 'Yusuf Bello', role: 'customer', tel: '+234-805-555-0404' }
    ],
    dialogs: [
      { body: 'Every day between 2pm and 5pm our internet becomes unusable. This has been going on for two weeks.', parties: [1], start_time: daysAgo(6) },
      { body: 'I will run diagnostics on your connection during those hours and get back to you with findings.', parties: [0], start_time: daysAgo(6) }
    ],
    tags: ['branch:Lagos', 'status:open', 'priority:medium', 'channel:call', 'issue_category:network'],
    summary: 'Recurring peak-hour latency issues. Agent running diagnostics.',
    sentiment: { label: 'negative', score: -0.3 },
    consent: { consent_given: false, consent_purpose: 'customer support analysis', consent_law: 'Nigeria NDPR' }
  },

  // ── NEW YORK: Open issue ──

  {
    subject: 'Integration with Salesforce CRM not syncing',
    created_at: daysAgo(1),
    parties: [
      { name: 'Sarah Chen', role: 'agent', mailto: 'sarah@techcorp.us' },
      { name: 'James Foster', role: 'customer', mailto: 'james@consulting.com' }
    ],
    dialogs: [
      { body: 'Our Salesforce integration stopped syncing contacts two days ago. We are missing critical customer data.', parties: [1], start_time: daysAgo(1) },
      { body: 'I can see the sync error in our logs. It appears your Salesforce API token expired. Let me guide you through re-authentication.', parties: [0], start_time: daysAgo(1) }
    ],
    tags: ['branch:New York', 'status:in_progress', 'priority:high', 'channel:email', 'issue_category:integration'],
    summary: 'Salesforce CRM integration sync failure due to expired API token. Agent guiding re-authentication.',
    sentiment: { label: 'negative', score: -0.2 },
    consent: { consent_given: true, consent_purpose: 'customer support analysis', consent_law: 'US TCPA', consent_granted_date: daysAgoDate(45), consent_expiry_date: daysFromNow(45) }
  }
];

// ── MAIN ──

console.log('');
console.log('TraceConnect — Seeding conversations...');
console.log('========================================');

for (const conv of conversations) {
  await createVcon(conv);
}

console.log('');
console.log(`Done. ${conversations.length} conversations seeded.`);
console.log('');
