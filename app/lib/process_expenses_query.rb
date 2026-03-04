class ProcessExpensesQuery
  def self.run(prompt)
    # 1. send the initial human query
    first_response = request(prompt, true)

    message = first_response.dig("choices", 0, "message")

    if message["tool_calls"]
      # 2. process ai decision to use a tool
      tool_data = process_response(message["tool_calls"])
      
      # 3. second request send the db results to get a normal language summarization
      send_results(prompt, message, tool_data)
    else
      message["content"]
    end
  rescue StandardError => e
    "Error: #{e.message}"
  end

  def self.process_response(tool_calls)
    tool_call = tool_calls.first
    method_name = tool_call.dig("function", "name")
    args = JSON.parse(tool_call.dig("function", "arguments"), symbolize_names: true)

    # Search for the method in FunctionCall model
    if FunctionCall.respond_to?(method_name)
      data = FunctionCall.send(method_name, **args)
      raise "No data found" if data.blank?

      { id: tool_call["id"], content: data.to_json }
    else
      raise "Method #{method_name} not found in FunctionCall"
    end
  end

  def self.send_results(prompt, original_message, tool_data)
    # send all previous chat with the db results of tool_data
    payload = [
      { role: "user", content: prompt },
      original_message,
      { role: "tool", tool_call_id: tool_data[:id], content: tool_data[:content] }
    ]

    response = request(payload, false)
    response.dig("choices", 0, "message", "content")
  end

  # ROLES: AI knows 3 roles:
  # system: Initial instructions (e.g., "You are a helpful accountant").
  # user: The "Customer" (Your prompt).
  # assistant: The "AI" (The response).

  def self.request(payload, is_human_query)
    client = OpenAI::Client.new(
      access_token: ENV.fetch("GEMINI_API_KEY"),
      uri_base: ENV.fetch("GEMINI_ENDPOINT"),
      log_erros: true
    )

    # before the conversation add a system message to set up the role of the AI
    system_message = {
      role: "system",
      content: "You are a helpful financial assistant. Today is #{Time.current.strftime('%A, %B %d, %Y')}. " \
                "Use the best function_tool available to get data before answering. Take into account total spendings. Do not use special formatting."
    }

    # the initial human written text must be added to user role (AI expected format)
    user_messages = payload.is_a?(String) ? [{ role: "user", content: payload }] : payload
    messages = [system_message] + user_messages

    params = {
      model: "gemini-2.5-flash", 
      messages: messages,
      temperature: is_human_query ? 0.1 : 0.6, #randomness and creativity (0 - accurate, strict; 1 - might hallucinate, more creative and picking cool words)
      tools: is_human_query ? Tool.expenses_tools : nil,
    }.compact

    response = client.chat(parameters: params)

    if response["error"]
      raise "Gemini API Error: #{response.dig('error', 'message')}"
    end

    response
  end
end

# example of response with a tool_call choice:
# {
#   "id": "chatcmpl-123",
#   "choices": [                      // <-- .dig("choices", 0, ...) multiple drafts of responses, the first one should be used
#                                     // can return more choices of answer if asked ( send parameter 'n' : number )
#     {
#       "index": 0,                   // <-- .dig(..., 0, ...)
#       "message": {                  // <-- .dig(..., "message")
#         "role": "assistant",
#         "content": null,             // this would normally have the text if i don't ask for a specific list of tools to be sent back
#         "tool_calls": [     //this part is available because I am sending a list of tools as params in the request, otherwise i would get plain language
#                             // the insides of tool_calls are based on the blueprint I sent from Tool.rb
#           {
#             "id": "call_abc123",    // <-- This is the tool_call ID
#             "type": "function",
#             "function": {
#               "name": "query_expenses",
#               "arguments": "{\"category_name\": \"Food\"}"
#             }
#           }
#         ]
#       },
#       "finish_reason": "tool_calls"
#     }
#   ]
# }