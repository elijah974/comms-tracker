# Daily Communication Audit

Run a daily audit of Slack and Gmail volume for yesterday. Count messages, categorize by theme, and append results to `data/daily-log.json`.

## Instructions

### 1. Determine yesterday's date

Calculate yesterday's date in YYYY-MM-DD format. Use this for all searches below.

### 2. Count Slack messages

Use the Slack MCP tools to search for messages from yesterday.

**My Slack user ID:** `U090JP8RST1`

Run these searches:
- **Received:** `slack_search_public_and_private` with query `to:<@U090JP8RST1>` filtered to yesterday. Count unique messages.
- **Sent:** `slack_search_public_and_private` with query `from:<@U090JP8RST1>` filtered to yesterday. Count unique messages.
- **Mentions:** `slack_search_public_and_private` with query `<@U090JP8RST1>` filtered to yesterday. Count unique messages.

### 3. Count Gmail messages

Use the Gmail MCP tools to search for threads from yesterday.

- **Inbox:** `search_threads` with query `after:YESTERDAY before:TODAY -label:sent -from:me`. Count threads.
- **Sent:** `search_threads` with query `after:YESTERDAY before:TODAY from:me`. Count threads.

**Exclude from all Gmail counts:**
- Mailreach warmup emails (subjects containing "warmup" or from domains containing "mailreach")
- Calendar invites (from `calendar-notification@google.com`)

### 4. Categorize by theme

Scan the messages found above and count how many match each theme:

| Theme | Channel | Match Criteria |
|-------|---------|----------------|
| Biz Support Tickets | slack | Messages from `U0B1RRN117S` (BizSupport Sling) OR in `#biz-support-all` channel |
| Stuck Shifts / Clock Corrections | slack | Messages containing "clock", "stuck", "IN_PROGRESS", "clock out", "no show" |
| Shift Scheduling | slack | Messages containing "post shift", "add to shift", "headcount", "slots", "staff" |
| Salesforce Errors | gmail | From `info@salesforce.com` with "error", "exception", or "failed" |
| Timesheet/Invoice | gmail | Subject or body containing "timesheet", "invoice", "PO", "purchase order" |
| COI Requests | gmail | Subject or body containing "COI", "certificate of insurance" |
| Build Failures | gmail | From `notify.railway.app` OR subject containing "build failed", "deploy failed" |
| Indeed Applications | gmail | From `indeedemail.com` |

A message can match multiple themes. Count each match.

### 5. Generate summary

Write a 1-2 sentence summary highlighting:
- The top theme by count
- Any notable changes (if prior data exists in daily-log.json)
- Any actionable observation

### 6. Append to daily-log.json

Read the current contents of `~/comms-tracker/data/daily-log.json`, parse it as a JSON array, and append a new record with this schema:

```json
{
  "date": "YYYY-MM-DD",
  "slack": {
    "received": <number>,
    "sent": <number>,
    "mentions": <number>
  },
  "gmail": {
    "inbox": <number>,
    "sent": <number>
  },
  "themes": [
    { "name": "<theme name>", "channel": "slack|gmail", "count": <number> }
  ],
  "totalVolume": <slack.received + gmail.inbox>,
  "summary": "<1-2 sentence summary>"
}
```

Only include themes with count > 0 in the themes array. Write the updated JSON array back to the file with 2-space indentation.

### 7. Commit and push

Run:
```bash
cd ~/comms-tracker && git add data/daily-log.json && git commit -m "audit: YYYY-MM-DD daily comm volume" && git push
```

Replace YYYY-MM-DD with yesterday's actual date.

## Important

- Do NOT fabricate counts. If a search returns no results, record 0.
- If an MCP tool errors or is unavailable, note it in the summary and record what you can.
- The `totalVolume` field is `slack.received + gmail.inbox` (inbound messages only).
- Keep the summary factual and brief.
