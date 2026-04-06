# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

puts "Cleaning database"
# Offer.destroy_all
Request.destroy_all
Donor.destroy_all
Charity.destroy_all
User.destroy_all

puts "Database clean :). #{Donor.count} donors, #{Charity.count} charities, #{User.count} users."
puts "#{Request.count} requests."

puts "Creating users"
user1 = User.create!(
  email: "tokyo-shelter@demo.org",
  password: "123456"
)

user4 = User.create!(
  email: "sam@donor.com",
  password: "123456"
)

puts "#{User.count} users created"

puts "Creating charities"

charity1 = Charity.create!(
  user: user1,
  city: "Tokyo",
  description: "Emergency shelter support for Single Mothers escaping from abuse (demo)",
  org_name: "Tokyo Single Mothers Shelter (DEMO)",
  region: "Kanto",
  shipping_address: "1-2-3 Demo, Shibuya-ku, Tokyo"
)

puts "Charity #{charity1.org_name} created."

puts "Creating donors."

donor1 = Donor.new(
  user: user4,
  city: "Tokyo",
  display_name: "Sam Samson",
  donor_type: "individual",
  region: "Kanto"
)

puts "Donor #{donor1.display_name} created."

puts "Creating requests."

request1 = Request.new(
  category: "electronics",
  charity: charity1,
  city: "Tokyo",
  condition: "working",
  description: "charger included",
  quantity_needed: 2,
  quantity_remaining: 2,
  region: "Kanto",
  status: "Submitted",
  title: "Laptops",
  units: "units",
  urgency: "High"
)

puts "Created request for #{request1.quantity_needed} #{request1.title}."

puts "Creating offers."

offer1 = Offer.new(
  can_ship_by: Date.today + 7.days,
  condition: "Used-good",
  donor: donor1,
  message: "Can ship next week",
  quantity_offered: 2,
  request: request1,
  status: "Submitted",
  tracking_number: ""
)

puts "Created offer for #{offer1.quantity_offered} for #{offer1.request.title} by #{offer1.donor.display_name}"
