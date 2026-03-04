Expense.destroy_all
Category.destroy_all

puts "Creating categories..."

categories_data = [
  { name: 'Food & Drinks', description: 'Groceries, restaurants, and coffee' },
  { name: 'Transport', description: 'Fuel, public transit, and taxi' },
  { name: 'Utilities', description: 'Electricity, water, internet, and rent' },
  { name: 'Entertainment', description: 'Movies, games, and hobbies' },
  { name: 'Healthcare', description: 'Pharmacy, doctors, and insurance' },
  { name: 'Shopping', description: 'Clothes, electronics, and gadgets' }
]

created_categories = categories_data.map do |data|
  Category.create!(data)
end

puts "Creating 100 expenses..."

currencies = ['EUR', 'USD', 'RON']

100.times do
  Expense.create!(
    amount: Faker::Number.decimal(l_digits: 2, r_digits: 2),
    currency: currencies.sample,
    category: created_categories.sample,
    description: Faker::Commerce.product_name,
    spent_at: Faker::Time.between(from: 1.year.ago, to: Time.now)
  )
end

puts "Seeds created successfully!"
puts "Categories: #{Category.count}"
puts "Expenses: #{Expense.count}"