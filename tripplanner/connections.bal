import ballerina/ai;

// Shared model provider (WSO2 provider, configured in Config.toml under
// [ballerina.ai.wso2ProviderConfig]). Every agent in the crew reuses it.
final ai:Wso2ModelProvider wso2ModelProvider = check ai:getDefaultModelProvider();
