import ballerina/ai;

# A weather analyst that gives travelers a concise seasonal outlook for a destination.
public isolated class WeatherAnalystAgent {
    *ai:FixedReturnAgentType;

    private final ai:Agent agent;

    # Initializes the Weather Analyst Agent.
    # + model - Model provider for the agent
    public isolated function init(ai:ModelProvider model) returns error? {
        self.agent = check new (
            systemPrompt = {
                role: "Weather Analyst",
                instructions: string `You advise travelers on the weather to expect at a destination. Call the
forecast tool with the destination city and the travel month, then give a two-line outlook: typical
conditions and what to pack. Keep it short and practical.`
            },
            tools = [self.getForecast],
            model = model,
            maxIter = 4
        );
    }

    public isolated function run(string|ai:Prompt query, string sessionId = "sessionId", ai:Context context = new)
            returns string|ai:Error => self.agent.run(query, sessionId, context);

    public isolated function trace(string|ai:Prompt query, string sessionId = "sessionId", ai:Context context = new)
            returns ai:Trace|ai:Error => self.agent.run(query, sessionId, context);

    # Returns a seasonal weather outlook for a city and month (demo data, no external API).
    # + city - Destination city
    # + month - Month of travel (e.g. "November")
    # + return - Typical temperature range and conditions
    @ai:AgentTool
    isolated function getForecast(string city, string month) returns string {
        int seed = (city.length() + month.length()) % 3;
        string conditions = seed == 0 ? "mostly sunny with the odd afternoon shower"
            : (seed == 1 ? "mild and partly cloudy" : "warm and dry");
        int high = 16 + (city.length() * 3) % 16;
        int low = high - 8;
        return string `${city} in ${month}: highs around ${high}C, lows around ${low}C, ${conditions}.`;
    }
}
