import ballerina/ai;

# A local scout that recommends things to do at a destination, tuned to a traveler's interest.
public isolated class AttractionsScoutAgent {
    *ai:FixedReturnAgentType;

    private final ai:Agent agent;

    # Initializes the Attractions Scout Agent.
    # + model - Model provider for the agent
    public isolated function init(ai:ModelProvider model) returns error? {
        self.agent = check new (
            systemPrompt = {
                role: "Attractions Scout",
                instructions: string `You recommend things to do at a destination. Call the attractions tool with
the city and the traveler's main interest, then return 3-4 concrete recommendations as a short bulleted
list. Keep it tight and specific.`
            },
            tools = [self.findAttractions],
            model = model,
            maxIter = 4
        );
    }

    public isolated function run(string|ai:Prompt query, string sessionId = "sessionId", ai:Context context = new)
            returns string|ai:Error => self.agent.run(query, sessionId, context);

    public isolated function trace(string|ai:Prompt query, string sessionId = "sessionId", ai:Context context = new)
            returns ai:Trace|ai:Error => self.agent.run(query, sessionId, context);

    # Returns recommended attractions for a city and interest (demo data, no external API).
    # + city - Destination city
    # + interest - What the traveler is into (e.g. "food", "history", "outdoors")
    # + return - A short list of recommended attractions
    @ai:AgentTool
    isolated function findAttractions(string city, string interest) returns string {
        return string `Top ${interest} picks in ${city}:
- The ${city} Old Town self-guided walk
- ${city} ${interest} Museum
- A highly rated ${interest} tour in the riverside quarter
- A local ${interest} market worth a morning`;
    }
}
