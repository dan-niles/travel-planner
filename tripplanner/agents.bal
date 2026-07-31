import ballerina/ai;

import danniles/budget;
import danniles/destinationresearch;
import danniles/logistics;

// ---- The specialist crew (level-2 agents) ----
// Each is its own package. Destination Researcher and Logistics Coordinator in turn
// delegate to their OWN sub-agents (level 3), giving a main -> sub -> sub hierarchy.

final destinationresearch:DestinationResearchAgent destinationResearchAgent = check new (wso2ModelProvider);
final logistics:LogisticsCoordinatorAgent logisticsAgent = check new (wso2ModelProvider);
final budget:BudgetAnalystAgent budgetAgent = check new (wso2ModelProvider);

# Delegates destination research (weather to expect + things to do) to the Destination Researcher.
# + context - Engagement context injected by the runtime; forwarded so sub-agents share it
# + query - What to research about the destination
# + sessionId - Conversation handle; reuse to continue the thread
# + return - The destination profile
@ai:AgentTool
isolated function destinationResearchTool(ai:Context context, string query, string sessionId = "") returns string|error {
    string response = check destinationResearchAgent.run(query, sessionId, context);
    return response;
}

# Delegates travel logistics (flights + hotels) to the Logistics Coordinator.
# + context - Engagement context injected by the runtime; forwarded so sub-agents share it
# + query - What to arrange (route, dates, style, budget hints)
# + sessionId - Conversation handle; reuse to continue the thread
# + return - The proposed flights and stay
@ai:AgentTool
isolated function logisticsTool(ai:Context context, string query, string sessionId = "") returns string|error {
    string response = check logisticsAgent.run(query, sessionId, context);
    return response;
}

# Delegates cost estimation and budget checking to the Budget Analyst.
# + context - Engagement context injected by the runtime
# + query - The figures to total and the budget to check against
# + sessionId - Conversation handle; reuse to continue the thread
# + return - A cost breakdown and whether it fits the budget
@ai:AgentTool
isolated function budgetTool(ai:Context context, string query, string sessionId = "") returns string|error {
    return budgetAgent.run(query, sessionId, context);
}

// ---- Trip Planner (orchestrator, level 1) ----

final ai:InMemoryShortTermMemoryStore memoryStore = check new ();
final ai:ShortTermMemory shortTermMemory = check new (memoryStore);

@display {
    label: "",
    disabled: false
}
final ai:Agent tripPlannerAgent = check new (
    systemPrompt = {
        role: "Trip Planner",
        instructions: string `You are a travel planner who plans a trip end to end. Break the request into
the few sub-tasks it actually needs and delegate each to the right specialist:
* Destination Researcher — what the place is like: weather to expect and things to do.
* Logistics Coordinator — getting there and staying there: flights and hotels.
* Budget Analyst — ONLY when the user gives figures or asks about cost/budget; it totals flights,
lodging and daily spend and checks the budget.

Call each specialist at most once unless the user explicitly asks for more depth. Then synthesize one
clear itinerary with sections: When & Weather, What To Do, Getting There & Staying, and (only if costed)
Budget. Base every detail strictly on what the specialists return — do not invent prices, places or facts.`
    },
    memory = shortTermMemory,
    maxIter = 30,
    model = wso2ModelProvider,
    tools = [destinationResearchTool, logisticsTool, budgetTool]
);
final ai:Agent mathTutorAgent = check new (
    systemPrompt = {role: string `math tutor`, instructions: string `teach math`}, model = check ai:getDefaultModelProvider()
);
