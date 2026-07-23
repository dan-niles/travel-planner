import ballerina/ai;
import ballerina/http;
import ballerina/uuid;

listener ai:Listener travelListener = new (listenOn = check new http:Listener(9091, timeout = 300));

// Chat endpoint backed by the Trip Planner, which delegates to its specialist crew
// (and their sub-agents). POST to /travel/chat with { "message": "...", "sessionId": "..." }.
service /travel on travelListener {
    resource function post chat(@http:Payload ai:ChatReqMessage request) returns ai:ChatRespMessage|error {
        ai:Context context = new;
        context.set("requestId", uuid:createType1AsString());
        context.set("tenantId", "demo-traveler");

        string response = check tripPlannerAgent.run(request.message, request.sessionId, context);
        return {message: response};
    }
}
