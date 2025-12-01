puts "Cleaning database..."
Cities.destroy_all

puts "Creating cities..."
City.create!(name: "Barcelona")
puts "Created Barcelona"
puts "Creating cities..."
City.create!(name: "Tokyo")
puts "Created Tokyo"
puts "Creating cities..."
City.create!(name: "Paris")
puts "Created Paris"
puts "Creating cities..."
City.create!(name: "New York")
puts "Created New York"
puts "Creating cities..."
City.create!(name: "Sydney")
puts "Created Sydney"
puts "Creating cities..."
City.create!(name: "Amsterdam")
puts "Created Amsterdam"
puts "Creating cities..."
City.create!(name: "London")
puts "Created London"
puts "Creating cities..."
City.create!(name: "Lima")
puts "Created Lima"
puts "Creating cities..."
City.create!(name: "New Dehli")
puts "Created New Dehli"
puts "Creating cities..."
City.create!(name: "Phnom Penh")
puts "Created Phnom Penh"
puts "Creating cities..."
City.create!(name: "Budapest")
puts "Created Budapest"
puts "Creating cities..."
City.create!(name: "Cairo")
puts "Created Cairo"

puts "Finished! Created #{Cities.count} cities."
