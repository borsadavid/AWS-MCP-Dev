class CreateExpenses < ActiveRecord::Migration[6.1]
  def change
    create_table :expenses do |t|
      t.string :currency, default: "EUR", null: false
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.datetime :spent_at, null: false
      t.text :description

      t.references :category, null: false, foreign_key: true

      t.timestamps
    end
  end
end
