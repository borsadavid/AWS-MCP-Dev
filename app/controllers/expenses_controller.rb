class ExpensesController < ApplicationController
  def index
    @expenses = Expense.order(spent_at: :desc).limit(100)
    @categories = Category.all
  end

  def create
    @expense = Expense.create!(expense_params)
    @expense.broadcast_prepend_to "expenses", 
                                 target: "expenses_list", 
                                 partial: "expenses/expense", 
                                 locals: { expense: @expense }
    head :ok
  end

  def destroy
    @expense = Expense.find(params[:id])
    @expense.destroy!
    @expense.broadcast_remove_to "expenses", target: "expense_#{@expense.id}"
    head :ok
  end

  def query
    return unless params[:prompt]
    @result = ProcessExpensesQuery.run(params[:prompt])

    render turbo_stream: [
      turbo_stream.replace("query_results", partial: "expenses/result", locals: { result: @result }),
    ]
  end

  private

  def expense_params
    params.require(:expense).permit(:amount, :currency, :category_id, :description, :spent_at)
  end
end
