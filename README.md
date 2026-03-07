# TraceConnect

### Trace the conversation. Connect the dots.

A **VCON-powered Conversation Radar** that gives HQ real-time visibility into how customer issues are resolved across global branches — with consent-aware AI, cross-border compliance, and performance insights.

**Built for [VCONIC TADHack 2026](https://tadhack.com) (March 7-8) | Designed for the VCON App Store**

---

## The Problem

In a global call center, each branch handles its own region. HQ is completely blind:

- A product defect generates complaints in Lagos on Monday — Nairobi gets the same complaints by Wednesday — nobody connects the dots until the weekly meeting
- HQ has no way to compare how branches handle the same type of issue
- When HQ gets a complaint about a branch, they have to call the branch manager instead of looking at the conversation trail
- Each country has different data protection laws — HQ cannot verify branches are handling consent correctly
- Conversations are the most valuable business data, but they are scattered, unsearchable, and forgotten

## The Solution

TraceConnect captures conversations (calls, emails, chats) from each branch into VCON format and gives HQ four dashboards:

| Dashboard | What it does |
|-----------|-------------|
| **Radar** | See all branches at once, spot patterns across regions instantly |
| **Conversations** | Trace any conversation chain without calling the branch manager |
| **Consent** | Verify each branch handles consent correctly per their country's data protection law |
| **Performance** | Compare branches, identify top performers, surface what works |

Plus **AI-powered queries** via Claude Desktop and VCON MCP Server — ask natural language questions across all branch data.

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
|   VCON MCP Server         |  Node.js/TypeScript
|   (provided by hackathon) |  Semantic, keyword, hybrid search
+------------+--------------+
             |
             | Supabase Client
             |
+------------+--------------+
|   Supabase PostgreSQL     |  Single source of truth
|   (vCon data store)       |  pgvector for semantic search
+------------+--------------+
             |
             | DATABASE_URL (read from same DB)
             |
+------------+--------------+
|   Rails App (Dashboard)   |  TraceConnect
|   - Radar Dashboard       |  ERB + Stimulus + Turbo
|   - Conversations Feed    |  Chartkick for charts
|   - Consent Dashboard     |  Tailwind CSS 4.0
|   - Performance Board     |
+---------------------------+
```

Both the VCON MCP Server and the Rails app read from the same Supabase PostgreSQL database. The MCP server handles AI queries via Claude Desktop. The Rails app provides the visual dashboard.

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Framework | Ruby on Rails 8.1 |
| Ruby | 3.4.3 |
| Database | Supabase PostgreSQL (shared with VCON MCP Server) |
| Frontend | ERB + Turbo + Stimulus (Hotwire) |
| CSS | Tailwind CSS 4.0 + custom design system |
| Charts | Chartkick + Groupdate |
| Assets | Propshaft + ImportMap |
| AI Layer | Claude Desktop via VCON MCP Server |

---

## Pages

### 1. Radar Dashboard (`/`)

The HQ command center. One glance tells you everything.

- **Branch cards** for Nairobi, Lagos, and New York showing open issues, resolution times, and consent status
- **Pattern alerts** — detects the same complaint across 2+ branches before the weekly meeting (killer feature)
- **Quick stats** — total conversations, resolution rate, top performer

### 2. Conversations Feed (`/conversations`)

Searchable, filterable conversation list. Trace any conversation without calling the branch manager.

- Filter by branch, status, channel, priority, or search text
- Click any conversation to see the full trail — customer message, agent response, supervisor notes
- AI summary, sentiment score, and consent info per conversation

### 3. Consent Dashboard (`/consent`)

What makes TraceConnect stand out. Each branch operates under different data protection laws.

- Per-branch consent overview: Kenya DPA, Nigeria NDPR, US TCPA
- Expiration alerts — conversations with consent expiring in 7 days
- Expired consent shown grayed out — AI access automatically blocked
- Compliance percentage per branch with progress bars

### 4. Performance Board (`/performance`)

Compare branches and surface what works.

- Resolution time by branch (bar chart)
- Sentiment score averages by branch
- Top 5 agents by resolved issues
- Issue category breakdown per branch

---

## Setup

### Prerequisites

- Ruby 3.4.3
- PostgreSQL (or a Supabase account)
- Node.js (for seed scripts and Tailwind)
- Bundler

### Installation

```bash
# Clone the repository
git clone git@github.com:G-vans/TraceConnect.git
cd TraceConnect

# Install dependencies
bundle install

# Set up environment variables
cp .env.example .env
# Edit .env and add your DATABASE_URL (Supabase PostgreSQL connection string)

# Start the server
bin/dev
```

### Environment Variables

Create a `.env` file in the project root:

```
DATABASE_URL=postgresql://postgres.[project-ref]:[password]@aws-0-[region].pooler.supabase.com:6543/postgres
```

### Seed Data

The database is shared with the VCON MCP Server. Seed data can be loaded via:

```bash
# Option 1: SQL (direct to Supabase)
psql $DATABASE_URL -f scripts/seed_data.sql

# Option 2: Node.js (via Supabase SDK)
node scripts/seed_conversations.mjs
```

This creates 18 conversations across 3 branches with agents, dialogs, AI analysis, consent data, and tags.

---

## Project Structure

```
app/
  controllers/
    radar_controller.rb          # Radar Dashboard — branch overview + pattern detection
    conversations_controller.rb  # Conversations Feed — filters + detail view
    consent_controller.rb        # Consent Dashboard — compliance tracking
    performance_controller.rb    # Performance Board — charts + rankings
  models/
    vcon.rb                      # Main VCON record (parties, dialogs, analysis)
    party.rb                     # Agents, customers, supervisors
    dialog.rb                    # Conversation segments
    analysis.rb                  # AI analysis — sentiment, summaries
    vcon_attachment.rb           # Tags and consent data
  views/
    radar/index.html.erb         # Branch cards, pattern alerts, quick stats
    conversations/
      index.html.erb             # Filterable conversation list
      show.html.erb              # Full conversation trail + sidebar
    consent/index.html.erb       # Per-branch consent overview
    performance/index.html.erb   # Charts and agent rankings
    layouts/application.html.erb # Shared nav with TraceConnect branding
scripts/
  seed_data.sql                  # SQL seed data (18 conversations)
  seed_conversations.mjs         # Node.js seed script (Supabase SDK)
```

---

## VCON Features Demonstrated

| Capability | How TraceConnect Uses It |
|-----------|------------------------|
| **vCon Standard** | Conversations stored as proper vCons with parties, dialog, analysis, and attachments |
| **MCP Integration** | Claude Desktop queries all data via semantic, keyword, and hybrid search |
| **Consent Lifecycle** | Dedicated dashboard with per-country tracking, expiration alerts, and access blocking |
| **Tags & Metadata** | Branch, status, priority, channel, and issue category tags for filtering |
| **Analysis** | Sentiment scores and AI summaries per conversation |
| **Cross-border Compliance** | Kenya DPA, Nigeria NDPR, US TCPA — each branch tracked separately |

---

## Consent Lifecycle

Each vCon includes consent data as an attachment:

- **consent_given** — whether consent was granted
- **consent_purpose** — what the data is used for (support analysis, quality monitoring)
- **consent_law** — applicable law (Kenya DPA, Nigeria NDPR, US TCPA)
- **consent_granted_date** / **consent_expiry_date** — validity window
- **consent_scope** — what data is covered

The Consent Dashboard shows which conversations HQ can legally analyze, which are expiring soon, and which have expired. Expired consent blocks AI access automatically.

---

## Sample Data

### Branches
- **Nairobi, Kenya** — Agents: Amina, Joseph, Wanjiku, Ochieng | Supervisor: Kamau
- **Lagos, Nigeria** — Agents: Chioma, Emeka, Ngozi | Supervisor: Adebayo
- **New York, USA** — Agents: Sarah, Michael, David | Supervisor: Jennifer

### Scenarios
- **Pattern Detection** — SmartRouter Pro overheating complaints appear in Lagos (Mon-Tue) then Nairobi (Wed)
- **Performance Gap** — Nairobi resolves billing complaints in 1-3 hours, Lagos takes 1-2 days
- **Consent Expiry** — 2 Lagos conversations have expired NDPR consent (grayed out, AI blocked)
- **Top Performer** — Amina (Nairobi) with 4 resolved issues, all positive sentiment

---

## Claude Desktop AI Queries

With the VCON MCP Server connected to Claude Desktop, ask questions like:

- *"Are there similar complaints across multiple branches?"* — Pattern detected: SmartRouter Pro overheating
- *"Compare resolution times for billing issues across branches"* — Nairobi 2hrs vs Lagos 18hrs
- *"Which agent resolved the most issues this week?"* — Amina, 4 issues, positive sentiment
- *"Show me conversations with expired consent"* — 2 Lagos conversations under NDPR

---

## VCON App Store

TraceConnect is designed to plug into the VCON App Store that MindMaking is building. Any ITSP, MSP, or reseller serving companies with distributed teams can offer this as a service. The consent layer makes it compliant out of the box.

---

## License

Built for VCONIC TADHack 2026 by **Jevans**.
