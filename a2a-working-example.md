# Simple A2A TypeScript Example: Weather Agent

This document provides a complete, working example of the Agent2Agent (A2A) protocol implementation in TypeScript. It demonstrates how to create an A2A server (Weather Agent) and multiple client implementations.

## Table of Contents

1. [Setup](#setup)
2. [Weather Agent Server](#weather-agent-server)
3. [Simple Client](#simple-client)
4. [Streaming Client](#streaming-client)
5. [Multi-Agent Orchestration](#multi-agent-orchestration)
6. [Running the Example](#running-the-example)

## Setup

### Install Dependencies

```bash
# Create project
mkdir weather-agent-a2a
cd weather-agent-a2a
npm init -y

# Install dependencies
npm install @a2a-js/sdk express uuid
npm install -D @types/express @types/node @types/uuid typescript tsx

# Initialize TypeScript
npx tsc --init
```

## Weather Agent Server (A2A Server)

This server implements a weather information agent that responds to weather queries.

```typescript
// server.ts
import express from "express";
import { v4 as uuidv4 } from "uuid";
import type { AgentCard, Message, Task } from "@a2a-js/sdk";
import {
  AgentExecutor,
  RequestContext,
  ExecutionEventBus,
  DefaultRequestHandler,
  InMemoryTaskStore,
  TaskStatusUpdateEvent,
  TaskArtifactUpdateEvent
} from "@a2a-js/sdk/server";
import { A2AExpressApp } from "@a2a-js/sdk/server/express";

// 1. Define the Agent Card (published at /.well-known/agent-card.json)
const weatherAgentCard: AgentCard = {
  name: "weather_agent",
  description: "Provides weather information for any city",
  protocolVersion: "0.3.0",
  version: "1.0.0",
  url: "http://localhost:4000/",
  defaultInputModes: ["text", "text/plain"],
  defaultOutputModes: ["text", "text/plain"],
  capabilities: {
    streaming: true,
    pushNotifications: false,
    stateTransitionHistory: true,
  },
  skills: [
    {
      id: "get_weather",
      name: "Get Weather",
      description: "Get current weather for a city",
      tags: ["weather", "forecast"],
      examples: [
        "What's the weather in New York?",
        "Tell me the weather in London"
      ]
    }
  ]
};

// 2. Mock weather data
const weatherData: Record<string, any> = {
  "new york": { temp: 72, condition: "Sunny", humidity: 65 },
  "london": { temp: 58, condition: "Cloudy", humidity: 80 },
  "tokyo": { temp: 68, condition: "Partly Cloudy", humidity: 70 },
  "paris": { temp: 65, condition: "Rainy", humidity: 85 }
};

// 3. Implement the Agent Executor (core logic)
class WeatherAgentExecutor implements AgentExecutor {
  
  async execute(
    requestContext: RequestContext,
    eventBus: ExecutionEventBus
  ): Promise<void> {
    const { taskId, contextId } = requestContext;
    
    // Get user input from the message
    const userInput = this.extractUserInput(requestContext);
    console.log(`📥 Received request: ${userInput}`);
    
    // 1. Publish initial task with 'submitted' state
    const initialTask: Task = {
      kind: "task",
      id: taskId,
      contextId: contextId,
      status: {
        state: "submitted",
        timestamp: new Date().toISOString(),
      },
    };
    eventBus.publish(initialTask);
    
    // 2. Update to 'working' state
    const workingUpdate: TaskStatusUpdateEvent = {
      kind: "status-update",
      taskId: taskId,
      contextId: contextId,
      status: {
        state: "working",
        timestamp: new Date().toISOString(),
      },
      final: false,
    };
    eventBus.publish(workingUpdate);
    
    // 3. Process the request
    await new Promise(resolve => setTimeout(resolve, 500)); // Simulate processing
    
    const city = this.extractCity(userInput);
    const weather = this.getWeather(city);
    
    // 4. Create response message
    const responseMessage: Message = {
      kind: "message",
      messageId: uuidv4(),
      role: "agent",
      contextId: contextId,
      parts: [{
        kind: "text",
        text: weather
      }]
    };
    eventBus.publish(responseMessage);
    
    // 5. Create artifact with structured weather data
    if (city && weatherData[city.toLowerCase()]) {
      const artifactUpdate: TaskArtifactUpdateEvent = {
        kind: "artifact-update",
        taskId: taskId,
        contextId: contextId,
        artifact: {
          artifactId: `weather-${city}-${Date.now()}`,
          name: `weather_${city}.json`,
          parts: [{
            kind: "data",
            data: {
              city: city,
              ...weatherData[city.toLowerCase()],
              timestamp: new Date().toISOString()
            }
          }]
        }
      };
      eventBus.publish(artifactUpdate);
    }
    
    // 6. Mark task as completed
    const completedUpdate: TaskStatusUpdateEvent = {
      kind: "status-update",
      taskId: taskId,
      contextId: contextId,
      status: {
        state: "completed",
        timestamp: new Date().toISOString(),
      },
      final: true,
    };
    eventBus.publish(completedUpdate);
    
    eventBus.finished();
  }
  
  async cancelTask(
    taskId: string,
    eventBus: ExecutionEventBus
  ): Promise<void> {
    console.log(`❌ Task ${taskId} cancelled`);
    // Implement cancellation logic if needed
  }
  
  private extractUserInput(context: RequestContext): string {
    const message = context.message;
    if (message && message.parts && message.parts.length > 0) {
      const textPart = message.parts.find(p => p.kind === "text");
      return textPart?.text || "";
    }
    return "";
  }
  
  private extractCity(input: string): string | null {
    const cityMatch = input.match(/weather\s+(?:in|for)\s+(\w+(?:\s+\w+)?)/i);
    return cityMatch ? cityMatch[1] : null;
  }
  
  private getWeather(city: string | null): string {
    if (!city) {
      return "I couldn't identify the city. Please ask: 'What's the weather in [city]?'";
    }
    
    const cityLower = city.toLowerCase();
    const data = weatherData[cityLower];
    
    if (!data) {
      return `Sorry, I don't have weather data for ${city}. Try: New York, London, Tokyo, or Paris.`;
    }
    
    return `🌤️ Weather in ${city}:\n` +
           `Temperature: ${data.temp}°F\n` +
           `Condition: ${data.condition}\n` +
           `Humidity: ${data.humidity}%`;
  }
}

// 4. Setup and start the server
const PORT = 4000;

const agentExecutor = new WeatherAgentExecutor();
const taskStore = new InMemoryTaskStore();

const requestHandler = new DefaultRequestHandler(
  weatherAgentCard,
  taskStore,
  agentExecutor
);

const appBuilder = new A2AExpressApp(requestHandler);
const expressApp = appBuilder.setupRoutes(express());

expressApp.listen(PORT, () => {
  console.log(`🚀 Weather Agent Server started on http://localhost:${PORT}`);
  console.log(`📋 Agent Card: http://localhost:${PORT}/.well-known/agent-card.json`);
});
```

## Simple Client

Basic client that sends weather queries and receives responses.

```typescript
// client.ts
import { A2AClient, SendMessageSuccessResponse } from "@a2a-js/sdk/client";
import { MessageSendParams, Task, Message } from "@a2a-js/sdk";
import { v4 as uuidv4 } from "uuid";

async function testWeatherAgent() {
  console.log("🌐 Connecting to Weather Agent...\n");
  
  // 1. Create client from Agent Card URL (discovery phase)
  const client = await A2AClient.fromCardUrl(
    "http://localhost:4000/.well-known/agent-card.json"
  );
  
  console.log("✅ Connected! Agent Card retrieved successfully\n");
  
  // 2. Send a weather query
  const queries = [
    "What's the weather in New York?",
    "Tell me the weather in London",
    "How's the weather in Tokyo?"
  ];
  
  for (const query of queries) {
    console.log(`\n📤 Sending: "${query}"`);
    
    const sendParams: MessageSendParams = {
      message: {
        messageId: uuidv4(),
        role: "user",
        parts: [{ kind: "text", text: query }],
        kind: "message",
      },
    };
    
    // 3. Send message and receive response
    const response = await client.sendMessage(sendParams);
    
    if ("error" in response) {
      console.error("❌ Error:", response.error.message);
      continue;
    }
    
    // 4. Process the response
    const result = (response as SendMessageSuccessResponse).result;
    
    if (result.kind === "task") {
      const task = result as Task;
      console.log(`\n📦 Task Created: ${task.id}`);
      console.log(`   Status: ${task.status.state}`);
      
      // Check for message in task
      if (task.messages && task.messages.length > 0) {
        const agentMessage = task.messages.find(m => m.role === "agent");
        if (agentMessage && agentMessage.parts.length > 0) {
          console.log(`\n📨 Response:\n${agentMessage.parts[0].text}`);
        }
      }
      
      // Check for artifacts
      if (task.artifacts && task.artifacts.length > 0) {
        console.log(`\n📎 Artifacts:`);
        task.artifacts.forEach(artifact => {
          console.log(`   - ${artifact.name}`);
          if (artifact.parts[0].kind === "data") {
            console.log(`     Data:`, JSON.stringify(artifact.parts[0].data, null, 2));
          }
        });
      }
    } else {
      // Direct message response
      const message = result as Message;
      console.log(`\n📨 Response: ${message.parts[0].text}`);
    }
    
    console.log("\n" + "=".repeat(60));
  }
}

// Run the client
testWeatherAgent().catch(console.error);
```

## Streaming Client

Client that receives real-time updates via Server-Sent Events (SSE).

```typescript
// streaming-client.ts
import { A2AClient } from "@a2a-js/sdk/client";
import { MessageSendParams } from "@a2a-js/sdk";
import { v4 as uuidv4 } from "uuid";

async function streamWeatherUpdates() {
  console.log("🌐 Connecting to Weather Agent (Streaming)...\n");
  
  const client = await A2AClient.fromCardUrl(
    "http://localhost:4000/.well-known/agent-card.json"
  );
  
  const streamParams: MessageSendParams = {
    message: {
      messageId: uuidv4(),
      role: "user",
      parts: [{ kind: "text", text: "What's the weather in Paris?" }],
      kind: "message",
    },
  };
  
  try {
    console.log("📡 Starting stream...\n");
    
    const stream = client.sendMessageStream(streamParams);
    
    for await (const event of stream) {
      console.log(`\n🔔 Event Type: ${event.kind}`);
      
      if (event.kind === "task") {
        console.log(`   Task ID: ${event.id}`);
        console.log(`   Status: ${event.status.state}`);
      } 
      else if (event.kind === "status-update") {
        console.log(`   Task ID: ${event.taskId}`);
        console.log(`   New Status: ${event.status.state}`);
        console.log(`   Final: ${event.final}`);
      } 
      else if (event.kind === "message") {
        console.log(`   From: ${event.role}`);
        if (event.parts[0].kind === "text") {
          console.log(`   Message: ${event.parts[0].text}`);
        }
      } 
      else if (event.kind === "artifact-update") {
        console.log(`   Artifact: ${event.artifact.name}`);
        console.log(`   Artifact ID: ${event.artifact.artifactId}`);
        if (event.artifact.parts[0].kind === "data") {
          console.log(`   Data:`, JSON.stringify(event.artifact.parts[0].data, null, 2));
        }
      }
    }
    
    console.log("\n✅ Stream completed");
    
  } catch (error) {
    console.error("❌ Stream error:", error);
  }
}

// Run streaming client
streamWeatherUpdates().catch(console.error);
```

## Multi-Agent Orchestration

Example showing how one agent can orchestrate multiple specialized agents.

```typescript
// multi-agent-client.ts
import { A2AClient, SendMessageSuccessResponse } from "@a2a-js/sdk/client";
import { MessageSendParams, Task } from "@a2a-js/sdk";
import { v4 as uuidv4 } from "uuid";

class ShoppingOrchestrator {
  private weatherClient: A2AClient | null = null;
  private productClient: A2AClient | null = null;
  
  async initialize() {
    console.log("🔌 Connecting to agents...\n");
    
    // Connect to Weather Agent
    this.weatherClient = await A2AClient.fromCardUrl(
      "http://localhost:4000/.well-known/agent-card.json"
    );
    console.log("✅ Weather Agent connected");
    
    // In a real scenario, you'd connect to other agents too
    // this.productClient = await A2AClient.fromCardUrl(
    //   "http://localhost:5000/.well-known/agent-card.json"
    // );
    // console.log("✅ Product Agent connected");
  }
  
  async orchestrateWeatherBasedShopping(city: string) {
    console.log(`\n🎯 Orchestrating shopping for ${city} weather...\n`);
    
    if (!this.weatherClient) {
      throw new Error("Clients not initialized");
    }
    
    // Step 1: Get weather
    console.log("1️⃣ Getting weather information...");
    const weatherParams: MessageSendParams = {
      message: {
        messageId: uuidv4(),
        role: "user",
        parts: [{ kind: "text", text: `What's the weather in ${city}?` }],
        kind: "message",
      },
    };
    
    const weatherResponse = await this.weatherClient.sendMessage(weatherParams);
    
    if ("error" in weatherResponse) {
      throw new Error(`Weather request failed: ${weatherResponse.error.message}`);
    }
    
    const weatherTask = (weatherResponse as SendMessageSuccessResponse).result as Task;
    console.log(`   ✅ Weather data received`);
    
    // Extract weather data from artifact
    let weatherData: any = null;
    if (weatherTask.artifacts && weatherTask.artifacts.length > 0) {
      const artifact = weatherTask.artifacts[0];
      if (artifact.parts[0].kind === "data") {
        weatherData = artifact.parts[0].data;
        console.log(`   Temperature: ${weatherData.temp}°F`);
        console.log(`   Condition: ${weatherData.condition}`);
      }
    }
    
    // Step 2: Determine shopping needs based on weather
    console.log("\n2️⃣ Determining shopping needs...");
    let recommendedItems: string[] = [];
    
    if (weatherData) {
      if (weatherData.condition.toLowerCase().includes("rain")) {
        recommendedItems = ["umbrella", "raincoat"];
      } else if (weatherData.temp > 75) {
        recommendedItems = ["sunglasses", "sunscreen"];
      } else if (weatherData.temp < 60) {
        recommendedItems = ["jacket", "warm scarf"];
      } else {
        recommendedItems = ["light jacket"];
      }
    }
    
    console.log(`   Recommended items: ${recommendedItems.join(", ")}`);
    
    // Step 3: In a real scenario, query Product Agent for these items
    console.log("\n3️⃣ Would query Product Agent for:", recommendedItems);
    
    // Step 4: Return orchestrated result
    return {
      city,
      weather: weatherData,
      recommendations: recommendedItems
    };
  }
}

// Run multi-agent orchestration
async function runOrchestration() {
  const orchestrator = new ShoppingOrchestrator();
  await orchestrator.initialize();
  
  const result = await orchestrator.orchestrateWeatherBasedShopping("New York");
  
  console.log("\n📊 Final Result:");
  console.log(JSON.stringify(result, null, 2));
}

runOrchestration().catch(console.error);
```

## Running the Example

### Add Scripts to package.json

```json
{
  "scripts": {
    "server": "tsx server.ts",
    "client": "tsx client.ts",
    "stream": "tsx streaming-client.ts",
    "orchestrate": "tsx multi-agent-client.ts"
  }
}
```

### Run Commands

```bash
# Terminal 1 - Start the server
npm run server

# Terminal 2 - Run simple client
npm run client

# Or run streaming client
npm run stream

# Or run multi-agent orchestration
npm run orchestrate
```

## Expected Output

### Server Output

```
🚀 Weather Agent Server started on http://localhost:4000
📋 Agent Card: http://localhost:4000/.well-known/agent-card.json
📥 Received request: What's the weather in New York?
```

### Client Output

```
🌐 Connecting to Weather Agent...
✅ Connected! Agent Card retrieved successfully

📤 Sending: "What's the weather in New York?"

📦 Task Created: abc-123-def
   Status: completed

📨 Response:
🌤️ Weather in New York:
Temperature: 72°F
Condition: Sunny
Humidity: 65%

📎 Artifacts:
   - weather_New York.json
     Data: {
       "city": "New York",
       "temp": 72,
       "condition": "Sunny",
       "humidity": 65,
       "timestamp": "2025-11-13T..."
     }

============================================================
```

### Streaming Client Output

```
🌐 Connecting to Weather Agent (Streaming)...
📡 Starting stream...

🔔 Event Type: task
   Task ID: xyz-789-abc
   Status: submitted

🔔 Event Type: status-update
   Task ID: xyz-789-abc
   New Status: working
   Final: false

🔔 Event Type: message
   From: agent
   Message: 🌤️ Weather in Paris:
Temperature: 65°F
Condition: Rainy
Humidity: 85%

🔔 Event Type: artifact-update
   Artifact: weather_Paris.json
   Artifact ID: weather-Paris-1731513600000
   Data: {
  "city": "Paris",
  "temp": 65,
  "condition": "Rainy",
  "humidity": 85,
  "timestamp": "2025-11-13T..."
}

🔔 Event Type: status-update
   Task ID: xyz-789-abc
   New Status: completed
   Final: true

✅ Stream completed
```

## Key Concepts Demonstrated

1. **Agent Card Discovery** - Client fetches agent capabilities from `/.well-known/agent-card.json`
2. **Task Lifecycle** - Tasks transition through states: submitted → working → completed
3. **Messages & Parts** - Structured communication using typed message parts (text, data, files)
4. **Artifacts** - Structured outputs attached to tasks (e.g., JSON weather data)
5. **Streaming** - Real-time updates via Server-Sent Events (SSE)
6. **Multi-Agent Orchestration** - One agent delegates to multiple specialized agents
7. **Request/Response Pattern** - Standard JSON-RPC 2.0 over HTTP/HTTPS
8. **State Management** - In-memory task store for tracking ongoing work
9. **Event Bus** - Publishing status updates, messages, and artifacts during execution
10. **Error Handling** - Proper error responses and client-side error checking

## Architecture Overview

```
┌─────────────────┐
│  Client Agent   │
│  (Orchestrator) │
└────────┬────────┘
         │
         │ 1. GET /.well-known/agent-card.json
         │    (Discovery)
         │
         ▼
┌─────────────────┐
│  Weather Agent  │
│   (A2A Server)  │
└────────┬────────┘
         │
         │ 2. POST /  (JSON-RPC 2.0)
         │    Method: message/send
         │    Params: { message: {...} }
         │
         │ 3. Response
         │    Result: { task: {...} }
         │
         ▼
┌─────────────────┐
│  Task Executor  │
│  (Agent Logic)  │
└────────┬────────┘
         │
         │ 4. Publish Events
         │    - status-update
         │    - message
         │    - artifact-update
         │
         ▼
┌─────────────────┐
│   Event Bus     │
│ (Notification)  │
└─────────────────┘
```

## Next Steps

To extend this example, you could:

1. **Add Authentication** - Implement OAuth 2.0 or API key authentication
2. **Add Push Notifications** - Configure webhooks for long-running tasks
3. **Integrate vLEI** - Add verifiable organizational identity to Agent Cards
4. **Add More Agents** - Create product, payment, or delivery agents
5. **Implement Caching** - Cache Agent Cards and weather data
6. **Add Error Recovery** - Implement retry logic and circuit breakers
7. **Add Monitoring** - Integrate with observability platforms
8. **Deploy to Production** - Use proper hosting, TLS certificates, and load balancing

## Related Documentation

- [A2A Protocol Specification](https://a2aprotocol.ai/docs/specification/)
- [A2A JavaScript SDK](https://github.com/a2aproject/a2a-js)
- [Agent Development Kit (ADK)](https://google.github.io/adk-docs/)
- [AP2 Payment Protocol](https://ap2-protocol.org/)

---

**Created**: November 2025  
**Based on**: A2A Protocol v0.3.0  
**SDK Version**: @a2a-js/sdk latest
