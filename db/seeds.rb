# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# puts "Cleaning database"
# Offer.destroy_all
# Request.destroy_all
# Donor_profile.destroy_all
# Charity_profile.destroy_all

# puts "Database clean :)"

user1 = User.create(
  email: "tokyo-shelter@demo.org",
  password: "123456"
)

user4 = User.create(
  email: "sam@donor.com",
  password: "123456"
)

charity1 = CharityProfile.new(
  user: user1,
  city: "Tokyo",
  description: "Emergency shelter support for Single Mothers escaping from abuse (demo)",
  org_name: "Tokyo Single Mothers Shelter (DEMO)",
  region: "Kanto",
  shipping_address: "1-2-3 Demo, Shibuya-ku, Tokyo"
)

# donor1 = Donor.new(
#   user: user4,
#   city: "Tokyo",
#   display_name: "Sam Samson",
#   donor_type: "individual",
#   region: "Kanto"
# )

# request1 = Request.new(
#   category: "electronics",
#   charity: charity1,
#   city: "Tokyo",
#   condition: "working",
#   description: "charger included",
#   quantity_needed: 2,
#   quantity_remaining: 2,
#   region: "Kanto",
#   status: "Submitted",
#   title: "Laptops",
#   units: "units",
#   urgency: "High"
# )

# offer1 = Offer.new(
#   can_ship_by: Date.today + 7.days,
#   condition: "Used-good",
#   donor_profile: donor1,
#   message: "Can ship next week",
#   quantity_offered: 2,
#   request: request1,
#   status: "Submitted",
#   tracking_number: null
# )
