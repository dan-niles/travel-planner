import ballerina/ai;

# A flight finder that returns a few route options for a trip.
public isolated class FlightFinderAgent {
    *ai:FixedReturnAgentType;

    private final ai:Agent agent;

    # Initializes the Flight Finder Agent.
    # + model - Model provider for the agent
    public isolated function init(ai:ModelProvider model) returns error? {
        self.agent = check new (
            systemPrompt = {
                role: "Flight Finder",
                instructions: string `You find flight options for a route. Call the flight tool with the origin,
destination and travel date, then present the options as a short bulleted list and note the cheapest and
the fastest. Keep it concise.`
            },
            tools = [self.searchFlights],
            model = model,
            maxIter = 4
        );
    }

    public isolated function run(string|ai:Prompt query, string sessionId = "sessionId", ai:Context context = new)
            returns string|ai:Error => self.agent.run(query, sessionId, context);

    public isolated function trace(string|ai:Prompt query, string sessionId = "sessionId", ai:Context context = new)
            returns ai:Trace|ai:Error => self.agent.run(query, sessionId, context);

    # Returns flight options for a route and date (demo data, no external API).
    # + origin - Departure city
    # + destination - Arrival city
    # + date - Travel date (free text, e.g. "2025-11-12")
    # + return - A short list of flight options with prices
    @ai:AgentTool
    isolated function searchFlights(string origin, string destination, string date) returns string {
        int base = 140 + (origin.length() + destination.length()) * 23 % 420;
        return string `Flights ${origin} -> ${destination} on ${date}:
- SkyJet 204, nonstop, 3h10m, $${base}
- AeroLink 88, 1 stop, 5h45m, $${base - 45}
- Horizon 512, nonstop, 3h25m, $${base + 70}`;
    }
}
