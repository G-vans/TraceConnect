# TraceConnect
### Trace the conversation. Connect the dots.
## Conversation Radar for Distributed Teams
### VCONIC TADHack 2026 - March 7-8

---

## The Idea (One-liner)
A VCON-powered Conversation Radar that gives HQ real-time visibility into how customer issues are resolved across global branches - with consent-aware AI, cross-border compliance, and performance insights. Built for the VCON App Store.

---

## The Problem You Lived
In a global call center, each branch handles its own region. Nairobi handles Kenya, Lagos handles Nigeria, New York handles the US. Escalation happens within each branch - agent to supervisor to manager. But HQ is completely blind:

- HQ cant see whats happening without asking each branch manager for reports
- A product defect generates complaints in Lagos on Monday - Nairobi gets the same complaints by Wednesday - nobody connects the dots until the weekly meeting
- HQ has no way to compare how branches handle the same type of issue (Nairobi resolves billing complaints in 2 hours, Lagos takes 2 days - why?)
- A top-performing agent in New York has a great approach to refund requests, but that knowledge stays in New York
- When HQ gets complaints about a branch, they have to call the branch manager and ask what happened instead of looking at the conversation trail
- Each country has different data protection laws - HQ has no way to verify branches are handling consent correctly
- Conversations are the most valuable business data, but they are scattered, unsearchable, and forgotten

## The Solution
TraceConnect is a Conversation Radar for distributed teams. It captures conversations (calls, emails, chats) from each branch into VCON format and gives HQ:

1. RADAR VIEW - See all branches at once, spot patterns across regions before the weekly meeting
2. CONVERSATION TRAIL - Trace any conversation chain without calling the branch manager
3. AI-POWERED QUERIES - Ask Claude natural language questions across all branch data
4. CONSENT DASHBOARD - Verify each branch is handling consent correctly per their countrys data protection law
5. PERFORMANCE INSIGHTS - Compare branches, identify top performers, connect what works to where it is needed

---

## Architecture

```
+---------------------------+
|     Claude Desktop        |  AI-powered natural language queries
|     (AI Assistant)        |  "Which agent resolved the most issues?"
+------------+--------------+
             | MCP Protocol (stdio)
             |
+------------+--------------+
|   VCON MCP Server         |  Node.js/TypeScript (hackathon provided)
|   (set up, dont modify)   |  Handles AI search, tags, analytics
+------------+--------------+
             |
             | Supabase Client
             |
+------------+--------------+
|   Supabase PostgreSQL     |  Free tier - single source of truth
|   (vCon data store)       |  pgvector for semantic search
+------------+--------------+
             |
             | database.yml (read from same DB)
             |
+------------+--------------+
|   Rails App (Dashboard)   |  Your code
|   - Radar Dashboard       |  ERB + Stimulus + Turbo
|   - Conversations Feed    |  Chartkick for charts
|   - Consent Dashboard     |  Tailwind CSS
+---------------------------+
```

Both the VCON MCP Server and your Rails app read from the same Supabase PostgreSQL database. The MCP server handles AI queries via Claude Desktop. Your Rails app handles the visual dashboard.

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| VCON MCP Server | Node.js + TypeScript (provided, just set up) |
| Database | Supabase PostgreSQL + pgvector - free tier |
| AI Assistant | Claude Desktop (connected via MCP) |
| Dashboard | Ruby on Rails 7+ |
| Frontend | ERB views + Stimulus + Turbo |
| CSS | Tailwind CSS |
| Charts | Chartkick + Groupdate gems |
| Hosting | Local demo |

---

## Pages (3 Core + 1 Optional)

### Page 1: Radar Dashboard (Home)
The HQ command center. One glance tells you everything.

- Branch cards (Nairobi, Lagos, New York) showing:
  - Open issues count
  - Resolved today count
  - Average resolution time
  - Consent compliance status (green/yellow/red)
- PATTERN ALERT SECTION: "Same complaint detected in 2+ branches this week"
  - Shows matching issues across branches with count
  - This is the killer feature for the demo
- Quick stats: total conversations this week, resolution rate, top performer

### Page 2: Conversations Feed
Searchable, filterable conversation list. Trace any conversation.

- Filters (Stimulus controller):
  - Branch (Nairobi / Lagos / New York / All)
  - Status (Open / In Progress / Resolved)
  - Channel (Call / Email / Chat)
  - Priority (High / Medium / Low)
  - Date range
- Each row shows: subject, branch, agent, status, channel, sentiment, created date
- Click row to expand (Turbo Frame): full conversation trail
  - Shows dialog chain: customer message > agent response > supervisor note
  - Shows analysis: sentiment score, resolution summary
  - Shows consent: what consent was given, when it expires, under which law

### Page 3: Consent Dashboard
What makes TraceConnect stand out at THIS hackathon.

- Per-branch consent overview:
  - Nairobi: Kenya Data Protection Act - X conversations with valid consent, Y expiring soon
  - Lagos: Nigeria NDPR - X conversations with valid consent, Y expiring soon
  - New York: US regulations - X conversations with valid consent
- Consent timeline: when consents were given, when they expire
- Alert: "3 conversations in Lagos have consent expiring in 7 days"
- This directly uses the VCON consent extension that Thomas McCarty-Howe presented

### Page 4 (Optional): Performance Board
- Resolution times by branch (bar chart via Chartkick)
- Top 5 agents by resolved issues this week
- Issue categories breakdown per branch
- Sentiment score average per branch

---

## Rails App Structure

```
trace_connect/
  app/
    controllers/
      radar_controller.rb            # Page 1: Branch overview + patterns
      conversations_controller.rb    # Page 2: Filterable feed + detail
      consent_controller.rb          # Page 3: Consent dashboard
      performance_controller.rb      # Page 4: Performance board (optional)
    models/
      vcon.rb                        # Reads from Supabase vcons table
      party.rb                       # Agents, customers, supervisors
      dialog.rb                      # Conversation content
      analysis.rb                    # Sentiment, summaries
      attachment.rb                  # Tags + consent stored as attachments
    views/
      radar/
        index.html.erb               # Branch cards, pattern alerts, stats
      conversations/
        index.html.erb               # Filterable list
        _conversation.html.erb       # Turbo Frame partial for expand
      consent/
        index.html.erb               # Consent overview per branch
      performance/
        index.html.erb               # Charts and rankings
      layouts/
        application.html.erb         # Shared nav with TraceConnect branding
    javascript/
      controllers/
        filter_controller.js         # Stimulus: filters on conversations page
  config/
    database.yml                     # Points to Supabase PostgreSQL
```

---

## VCON Features Used (Judges Score Card)

| Judge Criteria | How TraceConnect Demonstrates It |
|---------------|-------------------------------|
| Understand vCon standard? | Conversations stored as proper vCons with parties, dialog, analysis, attachments |
| Use MCP properly? | Claude Desktop queries all data via semantic, keyword, and hybrid search |
| Demonstrate consent lifecycle? | DEDICATED consent dashboard showing per-country consent, expiration, alerts |
| Is it practical? | Built from real call center experience - solves a daily pain point |
| Is it monetizable? | Positioned for VCON App Store distribution via MindMaking |

---

## Consent Lifecycle (Deep Integration)

Each vCon includes:

```
Consent Extension Fields:
- consent_given: true/false
- consent_purpose: "customer support analysis" / "ai training" / "quality monitoring"
- consent_law: "Kenya DPA" / "Nigeria NDPR" / "US TCPA"
- consent_granted_date: "2026-02-15"
- consent_expiry_date: "2026-04-15" (e.g., 60 days)
- consent_parties: which parties consented
- consent_scope: what data is covered
```

The Consent Dashboard shows:
- Which conversations HQ can legally analyze (consent valid)
- Which are expiring soon (need renewal)
- Which have expired (AI access blocked)
- Breakdown by country/law

Demo line: "Notice these 3 Lagos conversations are grayed out - their consent expired last week under NDPR. TraceConnect blocks AI access automatically. Consent is not forever - TraceConnect respects that."

---

## VCON App Store Positioning

In the demo pitch, mention:
"TraceConnect is designed to plug into the VCON App Store that MindMaking is building. Any ITSP, MSP, or reseller serving companies with distributed teams can offer this as a service. The consent layer makes it compliant out of the box. This isnt just a hackathon project - its a product."

---

## Sample Data Scenarios (Seed Data)

### 3 Branches
1. Nairobi, Kenya - 4 agents (Amina, Joseph, Wanjiku, Ochieng) - Supervisor: Kamau
2. Lagos, Nigeria - 3 agents (Chioma, Emeka, Ngozi) - Supervisor: Adebayo
3. New York, USA - 3 agents (Sarah, Michael, David) - Supervisor: Jennifer

### 15-20 Conversations to Seed

PATTERN DETECTION SET (same product issue across branches):
- Lagos: 3 calls about "SmartRouter Pro overheating" (Mon-Tue)
- Nairobi: 2 calls about "SmartRouter Pro overheating" (Wed)
- These create the pattern alert on the dashboard

PERFORMANCE COMPARISON SET:
- Nairobi: 3 billing complaints resolved in 1-3 hours
- Lagos: 2 billing complaints resolved in 1-2 days
- Shows performance gap between branches

CONVERSATION TRAIL SET:
- Lagos: 1 detailed complaint with full trail (customer call > agent Emeka > supervisor Adebayo > resolution)
- Shows the value of tracing the trail without calling branch manager

CONSENT SCENARIOS:
- Nairobi conversations: consent under Kenya DPA, valid for 60 days
- Lagos conversations: 3 with valid NDPR consent, 2 with EXPIRED consent
- New York: all valid under US TCPA
- Expired ones show grayed out on consent dashboard

TOP PERFORMER SET:
- Amina (Nairobi): 4 resolved issues, all positive sentiment
- David (New York): 1 complex issue resolved after 3 days, positive outcome

---

## Timeline

### Tuesday (Today) - Brainstorm and Plan
- [x] Finalize idea: TraceConnect
- [x] Define pages and scope
- [x] Create build plan
- [x] Choose Rails for dashboard
- [x] Add consent dashboard and App Store positioning
- [x] Final name and tagline locked
- [ ] Register for hackathon (email info@tadhack.com)

### Wednesday (After work) - Setup Both Sides
VCON MCP Server side:
- [ ] Clone vcon-mcp repo
- [ ] Set up Supabase account (free tier)
- [ ] Get Supabase PostgreSQL connection string
- [ ] Configure .env with Supabase credentials
- [ ] Run npm install and npm run build
- [ ] Run database migrations
- [ ] Connect to Claude Desktop and test basic MCP tools

Rails side:
- [ ] rails new trace_connect --database=postgresql --css=tailwind
- [ ] Configure database.yml to point to Supabase PostgreSQL
- [ ] Create read-only models matching Supabase tables
- [ ] Verify Rails can read from vcons table
- [ ] Set up basic layout with TraceConnect branding and nav

### Thursday (After work) - Seed Data and Core Pages
- [ ] Create and run seed data script via Node.js (15-20 conversations)
- [ ] Tag all conversations (branch, status, priority, channel, issue_category)
- [ ] Add consent data to each conversation
- [ ] Verify Claude Desktop can query the data
- [ ] Build Radar Dashboard page (branch cards, pattern alerts)
- [ ] Start Conversations Feed page (list with filters)

### Friday (After work) - Complete All Pages
- [ ] Complete Conversations Feed with Turbo Frame expand
- [ ] Build Consent Dashboard page
- [ ] (Optional) Build Performance Board with Chartkick
- [ ] Test full flow: Radar > Conversations > Consent > Claude AI queries
- [ ] Prepare demo talking points

### Saturday - Polish and Submit
- [ ] Final testing of all pages
- [ ] Test 3-4 Claude Desktop query scenarios
- [ ] Record demo video (under 5 minutes)
- [ ] Write project description with App Store positioning
- [ ] Submit before deadline

---

## Gems to Add

```ruby
# Gemfile additions
gem "chartkick"    # Simple charts for performance page
gem "groupdate"    # Group by day/week/month for analytics
```

---

## Demo Script (5 minutes max)

### Opening (30 sec)
"Hi, I am Jevans. I built TraceConnect - a Conversation Radar for distributed teams. Trace the conversation. Connect the dots. I worked in a global call center and every week our HQ was blind to what was happening across branches. TraceConnect fixes that using VCON and MCP."

### Radar Dashboard (60 sec)
"Here is the HQ view. Three branches - Nairobi, Lagos, New York. I can instantly see Lagos has 5 open issues, Nairobi has 3. But look at this pattern alert - both branches received complaints about the same product this week. Without TraceConnect, nobody at HQ would know until Fridays report. Now they can trace it instantly."

### Conversations Feed (60 sec)
"Let me filter by Lagos. Here is a billing complaint. I click to expand and trace the full conversation - customer called, agent Emeka handled it, escalated to supervisor Adebayo, resolved in 4 hours. I traced all of this without calling a single person. Thats the connect part - connecting HQ to what actually happened."

### Consent Dashboard (60 sec)
"This is where TraceConnect stands out. Each branch operates under different data protection laws. Kenya follows their Data Protection Act, Nigeria follows NDPR, US follows TCPA. See these grayed out conversations in Lagos? Their consent expired last week. TraceConnect blocks AI access automatically. Consent is not forever - TraceConnect respects that."

### Claude Desktop AI Queries (90 sec)
Live demo:
- "Are there similar complaints across multiple branches?" > Pattern detected
- "Compare resolution times for billing issues across branches" > Nairobi 2hrs vs Lagos 18hrs
- "Which agent resolved the most issues this week?" > Amina, 4 issues, positive sentiment

### Closing (30 sec)
"TraceConnect is built to plug into the VCON App Store. Any company with distributed teams needs this - trace the conversation, connect the dots. The consent layer makes it compliant out of the box. Thank you."

---

## Key Selling Points for Judges

1. AUTHENTICITY - Built from real call center experience, not theory
2. VCON DEPTH - Uses store, search (semantic + keyword + hybrid), tags, analytics, consent, parties, analysis
3. CONSENT LIFECYCLE - Dedicated dashboard, per-country tracking, expiration alerts, access blocking
4. PATTERN DETECTION - Killer feature: AI spots same issue across branches before weekly meeting
5. COMMERCIAL VIABILITY - Positioned for VCON App Store via MindMaking
6. PROPER APP - Rails dashboard, not static files
7. PRIVACY FIRST - Consent-based, permission-controlled, aligned with data protection laws
8. THE NAME SAYS IT ALL - Trace the conversation. Connect the dots.

---

## Questions to Resolve

- [ ] Confirm hackathon registration (email info@tadhack.com)
- [ ] Do they require a video demo or live presentation?
- [ ] Any specific submission format?
- [ ] Check exact Supabase table schema after migrations run (to match Rails models)
- [ ] Verify VCON consent extension fields match what Thomas presented
