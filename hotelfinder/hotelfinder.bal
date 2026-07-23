import ballerina/ai;

# A hotel finder that returns a few stay options for a destination.
public isolated class HotelFinderAgent {
    *ai:FixedReturnAgentType;

    private final ai:Agent agent;

    # Initializes the Hotel Finder Agent.
    # + model - Model provider for the agent
    public isolated function init(ai:ModelProvider model) returns error? {
        self.agent = check new (
            systemPrompt = {
                role: "Hotel Finder",
                instructions: string `You find places to stay. Call the hotel tool with the city, number of nights
and the style (e.g. budget, mid-range, luxury), then present the options with nightly and total price as a
short bulleted list. Keep it concise.`
            },
            tools = [self.searchHotels],
            model = model,
            maxIter = 4
        );
    }

    public isolated function run(string|ai:Prompt query, string sessionId = "sessionId", ai:Context context = new)
            returns string|ai:Error => self.agent.run(query, sessionId, context);

    public isolated function trace(string|ai:Prompt query, string sessionId = "sessionId", ai:Context context = new)
            returns ai:Trace|ai:Error => self.agent.run(query, sessionId, context);

    # Returns hotel options for a city (demo data, no external API).
    # + city - Destination city
    # + nights - Number of nights
    # + style - Preferred style (e.g. "budget", "mid-range", "luxury")
    # + return - A short list of hotels with nightly and total price
    @ai:AgentTool
    isolated function searchHotels(string city, int nights, string style) returns string {
        int rate = 95 + (city.length() * 17) % 220;
        return string `${style} stays in ${city} for ${nights} night(s):
- The Grand ${city}, $${rate}/night (total $${rate * nights})
- ${city} Boutique Stay, $${rate - 30}/night (total $${(rate - 30) * nights})
- Riverside Inn, $${rate - 55}/night (total $${(rate - 55) * nights})`;
    }
}
