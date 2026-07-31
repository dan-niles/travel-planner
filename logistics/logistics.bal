import ballerina/ai;

import danniles/flightfinder;
import danniles/hotelfinder;

# A logistics coordinator. Arranges getting there and staying there by delegating to its
# own sub-agents: a Flight Finder and a Hotel Finder.
public isolated class LogisticsCoordinatorAgent {
    *ai:FixedTypedAgent;

    private final ai:Agent agent;
    private final flightfinder:FlightFinderAgent flightAgent;
    private final hotelfinder:HotelFinderAgent hotelAgent;

    # Initializes the Logistics Coordinator and its sub-agents.
    # + model - Model provider shared with the sub-agents
    public isolated function init(ai:ModelProvider model) returns error? {
        self.flightAgent = check new (model);
        self.hotelAgent = check new (model);
        self.agent = check new (
            systemPrompt = {
                role: "Logistics Coordinator",
                instructions: string `You arrange the travel logistics for a trip. Delegate:
* getting there (flights) to the flight finder tool,
* staying there (hotels) to the hotel finder tool.
Call each sub-agent at most once, then present a short plan: a recommended flight and a recommended stay
with prices. Base everything strictly on what the sub-agents return.`
            },
            tools = [self.flightFinderTool, self.hotelFinderTool],
            model = model,
            maxIter = 10
        );
    }

    public isolated function run(string|ai:Prompt query, string sessionId = "sessionId", ai:Context context = new)
            returns string|ai:Error => self.agent.run(query, sessionId, context);

    public isolated function trace(string|ai:Prompt query, string sessionId = "sessionId", ai:Context context = new)
            returns ai:Trace|ai:Error => self.agent.run(query, sessionId, context);

    # Delegates a flight search to the Flight Finder sub-agent.
    # + context - Engagement context injected by the runtime; forwarded to the sub-agent
    # + query - The flight request (include origin, destination and date)
    # + sessionId - Conversation handle; reuse to continue the thread
    # + return - Flight options
    @ai:AgentTool
    isolated function flightFinderTool(ai:Context context, string query, string sessionId = "") returns string|error {
        return self.flightAgent.run(query, sessionId, context);
    }

    # Delegates a hotel search to the Hotel Finder sub-agent.
    # + context - Engagement context injected by the runtime; forwarded to the sub-agent
    # + query - The hotel request (include city, nights and style)
    # + sessionId - Conversation handle; reuse to continue the thread
    # + return - Hotel options
    @ai:AgentTool
    isolated function hotelFinderTool(ai:Context context, string query, string sessionId = "") returns string|error {
        return self.hotelAgent.run(query, sessionId, context);
    }
}
