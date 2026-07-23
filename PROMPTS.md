# Demo prompts

Prompts chosen to exercise the nested agent hierarchy and produce a good-looking
Agent Flow diagram. POST each as `{"message": "<prompt>", "sessionId": "<id>"}` to
`http://localhost:9091/travel/chat`. Use a **fresh `sessionId`** per demo so each trace
starts clean.

Tip: the `curl` one-liners below are ready to paste.

---

## 1. Full hierarchy — the headline demo (all three levels, every branch)

Delegates to all three specialists; Destination Researcher and Logistics Coordinator
each fan out to two subagents, and Budget Analyst totals the cost. This is the widest,
deepest tree — the one to show your lead.

> Plan a 5-day trip to Kyoto in November for two people who love temples and food.
> We're flying from Singapore, want a mid-range hotel, and our total budget is about $4000.

```bash
curl -s http://localhost:9091/travel/chat -H 'Content-Type: application/json' \
  -d '{"message":"Plan a 5-day trip to Kyoto in November for two people who love temples and food. We are flying from Singapore, want a mid-range hotel, and our total budget is about $4000.","sessionId":"demo-full"}'
```

Expected shape:
`Trip Planner → Destination Researcher → (Weather Analyst, Attractions Scout)`,
`Trip Planner → Logistics Coordinator → (Flight Finder, Hotel Finder)`,
`Trip Planner → Budget Analyst`.

---

## 2. One deep branch — destination research only (2 levels on one branch)

Focuses on a single level-2 → level-3 branch. Good for explaining the "subagent has its
own subagents" idea without the whole tree.

> I'm visiting Lisbon in July — what weather should I expect and what should I do there?
> I'm mainly into food and history.

```bash
curl -s http://localhost:9091/travel/chat -H 'Content-Type: application/json' \
  -d '{"message":"I am visiting Lisbon in July - what weather should I expect and what should I do there? I am mainly into food and history.","sessionId":"demo-destination"}'
```

Expected: `Trip Planner → Destination Researcher → (Weather Analyst, Attractions Scout)`.

---

## 3. The other deep branch — logistics only

> Find me flights and a mid-range hotel for a 3-night trip from London to Barcelona
> on December 12th.

```bash
curl -s http://localhost:9091/travel/chat -H 'Content-Type: application/json' \
  -d '{"message":"Find me flights and a mid-range hotel for a 3-night trip from London to Barcelona on December 12th.","sessionId":"demo-logistics"}'
```

Expected: `Trip Planner → Logistics Coordinator → (Flight Finder, Hotel Finder)`.

---

## 4. Everything, family scale — biggest itinerary

> Put together a complete week-long itinerary for a family of four to Cape Town in
> December: what to expect and do, how to get there and where to stay from Dubai, and
> whether $8000 covers it.

```bash
curl -s http://localhost:9091/travel/chat -H 'Content-Type: application/json' \
  -d '{"message":"Put together a complete week-long itinerary for a family of four to Cape Town in December: what to expect and do, how to get there and where to stay from Dubai, and whether $8000 covers it.","sessionId":"demo-family"}'
```

---

## 5. Repeated invocation — show the ×N badge (optional)

Asks the planner to compare two destinations, which nudges it to call the Destination
Researcher **twice** — showing a single node with a `×2` badge and an expandable per-call
list in the diagram.

> Compare Rome and Athens for a spring city break for two — weather and top things to do
> in each — then tell me which you'd pick.

```bash
curl -s http://localhost:9091/travel/chat -H 'Content-Type: application/json' \
  -d '{"message":"Compare Rome and Athens for a spring city break for two - weather and top things to do in each - then tell me which you would pick.","sessionId":"demo-compare"}'
```

Expected: Destination Researcher invoked twice (Call 1 = Rome, Call 2 = Athens). Note:
whether the model calls it once or twice depends on the LLM's plan; re-run if needed.
