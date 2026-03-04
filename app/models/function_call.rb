class FunctionCall < ApplicationRecord
  def self.query_expenses(category_name: nil, min_amount: nil, max_amount: nil, currency: nil, start_date: nil, end_date: nil, description_keywords: nil)
    expenses = Expense.all
    expenses = expenses.joins(:category).where("categories.name ILIKE ?", category_name) if category_name.present?
    expenses = expenses.where("amount >= ?", min_amount) if min_amount
    expenses = expenses.where("amount <= ?", max_amount) if max_amount
    expenses = expenses.where(currency: currency) if currency
    expenses = expenses.where("spent_at >= ?", start_date) if start_date
    expenses = expenses.where("spent_at <= ?", end_date) if end_date
    expenses = expenses.where("expenses.description ILIKE ?", "%#{description_keywords}%") if description_keywords.present?

    totals_by_currency = expenses.group(:currency).sum(:amount)

    {
      total_amount: totals_by_currency,
      transaction_count: expenses.count,
      sample_data: expenses.order(spent_at: :desc).limit(10).map { |e| 
        "#{e.spent_at.to_date}: #{e.amount} #{e.currency} - #{e.description}" 
      }
    }
  end
end