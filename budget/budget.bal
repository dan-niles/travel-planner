import ballerina/ai;

# A budget analyst. Totals the cost of a trip from raw figures and checks it against a budget.
public isolated class BudgetAnalystAgent {
    *ai:FixedTypedAgent;

    private final ai:Agent agent;

    # Initializes the Budget Analyst Agent.
    # + model - Model provider for the agent
    public isolated function init(ai:ModelProvider model) returns error? {
        self.agent = check new (
            systemPrompt = {
                role: "Budget Analyst",
                instructions: string `You estimate the total cost of a trip and check it against a budget. Use the
cost tool to total flights, lodging and daily spending, then say whether it fits the traveler's budget and
where they could trim costs. Show the breakdown briefly. If a figure is missing, say so rather than guess.`
            },
            tools = [self.estimateTripCost],
            model = model,
            maxIter = 5
        );
    }

    public isolated function run(string|ai:Prompt query, string sessionId = "sessionId", ai:Context context = new)
            returns string|ai:Error => self.agent.run(query, sessionId, context);

    public isolated function trace(string|ai:Prompt query, string sessionId = "sessionId", ai:Context context = new)
            returns ai:Trace|ai:Error => self.agent.run(query, sessionId, context);

    # Totals the cost of a trip from its parts.
    # + flightCost - Round-trip flight cost per traveler
    # + hotelPerNight - Hotel nightly rate
    # + nights - Number of nights
    # + dailySpend - Daily spend per traveler (food, transport, activities)
    # + travelers - Number of travelers
    # + return - A cost breakdown and the grand total
    @ai:AgentTool
    isolated function estimateTripCost(decimal flightCost, decimal hotelPerNight, int nights,
            decimal dailySpend, int travelers) returns string {
        decimal flights = flightCost * <decimal>travelers;
        decimal lodging = hotelPerNight * <decimal>nights;
        decimal daily = dailySpend * <decimal>nights * <decimal>travelers;
        decimal total = flights + lodging + daily;
        return string `Flights: $${flights} (${travelers} x $${flightCost}), Lodging: $${lodging} ` +
            string `(${nights} x $${hotelPerNight}), Daily spend: $${daily} -> Grand total: $${total}`;
    }
}
