class Tool < ApplicationRecord
  def self.categories_data
    categories = Category.all
    {
      names: categories.pluck(:name),
      context: categories.map { |c| "#{c.name}: #{c.description}" }.join("; ")
    }
  end

  def self.expenses_tools
    category_info = categories_data

    [
      {
        type: "function",
        function: {
          name: "query_expenses",
          description: "Search and filter through the user's expenses. Use this to answer questions about spending, totals, or history.",
          parameters: {
            type: "object",
            properties: {
              category_name: { 
                type: "string", 
                enum: category_info[:names],
                description: "The name of the expense category. Available options: #{category_info[:context]}" 
              },
              min_amount: { 
                type: "number", 
                description: "Minimum amount spent (e.g., 50.0)." 
              },
              max_amount: { 
                type: "number", 
                description: "Maximum amount spent (e.g., 200.0)." 
              },
              currency: { 
                type: "string", 
                enum: ["EUR", "USD", "RON"],
                description: "The currency to filter by." 
              },
              start_date: { 
                type: "string", 
                format: "date", 
                description: "Filter expenses after this date (YYYY-MM-DD)." 
              },
              end_date: { 
                type: "string", 
                format: "date", 
                description: "Filter expenses before this date (YYYY-MM-DD)." 
              },
              description_keywords: { 
                type: "string", 
                description: "Keywords to search for in the expense description." 
              }
            },
            required: [] #AI can use any combination as no params are mandatory
          }
        }
      },
    ]
  end
end
