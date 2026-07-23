import ballerina/ai;

import danniles/attractionsscout;
import danniles/weatheranalyst;

# A destination researcher. Builds a short profile of a place by delegating to its own
# sub-agents: a Weather Analyst and an Attractions Scout.
public isolated class DestinationResearchAgent {
    *ai:FixedReturnAgentType;

    private final ai:Agent agent;
    private final weatheranalyst:WeatherAnalystAgent weatherAgent;
    private final attractionsscout:AttractionsScoutAgent attractionsAgent;

    # Initializes the Destination Researcher and its sub-agents.
    # + model - Model provider shared with the sub-agents
    public isolated function init(ai:ModelProvider model) returns error? {
        self.weatherAgent = check new (model);
        self.attractionsAgent = check new (model);
        self.agent = check new (
            systemPrompt = {
                role: "Destination Researcher",
                instructions: string `You build a short destination profile for a trip. Delegate:
* weather questions to the weather analyst tool,
* things-to-do questions to the attractions scout tool.
Call each sub-agent at most once, then synthesize a compact profile: a one-line weather outlook followed
by 3-4 recommended things to do. Base everything strictly on what the sub-agents return.`
            },
            tools = [self.weatherAnalystTool, self.attractionsScoutTool],
            model = model,
            maxIter = 10
        );
    }

    public isolated function run(string|ai:Prompt query, string sessionId = "sessionId", ai:Context context = new)
            returns string|ai:Error => self.agent.run(query, sessionId, context);

    public isolated function trace(string|ai:Prompt query, string sessionId = "sessionId", ai:Context context = new)
            returns ai:Trace|ai:Error => self.agent.run(query, sessionId, context);

    # Delegates a weather question to the Weather Analyst sub-agent.
    # + context - Engagement context injected by the runtime; forwarded to the sub-agent
    # + query - The weather question (include the city and travel month)
    # + sessionId - Conversation handle; reuse to continue the thread
    # + return - The weather outlook
    @ai:AgentTool
    isolated function weatherAnalystTool(ai:Context context, string query, string sessionId = "") returns string|error {
        return self.weatherAgent.run(query, sessionId, context);
    }

    # Delegates a things-to-do question to the Attractions Scout sub-agent.
    # + context - Engagement context injected by the runtime; forwarded to the sub-agent
    # + query - The things-to-do question (include the city and the traveler's interest)
    # + sessionId - Conversation handle; reuse to continue the thread
    # + return - Recommended attractions
    @ai:AgentTool
    isolated function attractionsScoutTool(ai:Context context, string query, string sessionId = "") returns string|error {
        return self.attractionsAgent.run(query, sessionId, context);
    }
}
