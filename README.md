# Travel Planner — nested multi-agent demo

A Ballerina AI project built to show a **three-level agent hierarchy** in the trace
visualizer's **Agent Flow** view: a main agent → subagents → their own subagents.

## The agent hierarchy

```
Trip Planner                     (level 1 — orchestrator)
├─ Destination Researcher          (level 2)
│  ├─ Weather Analyst              (level 3)  → getForecast tool
│  └─ Attractions Scout            (level 3)  → findAttractions tool
├─ Logistics Coordinator           (level 2)
│  ├─ Flight Finder                (level 3)  → searchFlights tool
│  └─ Hotel Finder                 (level 3)  → searchHotels tool
└─ Budget Analyst                  (level 2, leaf) → estimateTripCost tool
```

Each box is its own Ballerina package. Level-2 agents expose their level-3 subagents as
`@ai:AgentTool`s (the "agent-as-tool" pattern), so a single request fans out into a
nested tree of `invoke_agent` → `execute_tool` → `invoke_agent` spans — exactly what
Agent Flow is designed to visualize.

The leaf tools return **deterministic demo data** (no external APIs / tokens needed) —
only the LLM is called, via the WSO2 model provider configured in `Config.toml`.

## Run it

```bash
cd tripplanner
bal run
```

The service listens on **http://localhost:9091** with a chat endpoint at `/travel/chat`.

Send a request (reuse the same `sessionId` to continue a conversation):

```bash
curl -s http://localhost:9091/travel/chat \
  -H 'Content-Type: application/json' \
  -d '{"message":"Plan a 5-day trip to Kyoto in November for two people who love temples and food, budget about $4000.","sessionId":"demo-1"}'
```

See `PROMPTS.md` for demo prompts chosen to light up the full hierarchy.

## See the diagram

With tracing enabled (`idetraceprovider`, already set in `Config.toml`), each request
produces a trace. Open it in the VS Code **trace visualizer**, then click
**"View Agent Flow"** under the search bar to see the nested graph. Expand a node to see
its model/tool calls; click an agent that was invoked more than once to see each call.

## Configuration

`tripplanner/Config.toml` holds the WSO2 LLM provider credentials and the tracing
settings. It's git-ignored. If the copied access token expires, refresh it from your
working project's `Config.toml` (the `[ballerina.ai.wso2ProviderConfig]` block).
