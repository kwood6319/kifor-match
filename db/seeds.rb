puts "Cleaning database..."

Offer.destroy_all
Request.destroy_all
Donor.destroy_all
Charity.destroy_all
User.destroy_all

puts "Database clean :)! #{Donor.count} donors, #{Charity.count} charities, #{User.count} users."
puts "#{Request.count} requests, #{Offer.count} offers."

puts "----------------------------------------------"

puts "Creating users for charities..."

user1 = User.create!(
  email: "tokyo-shelter@demo.org",
  password: "123456"
)

user2 = User.create!(
  email: "osaka-food@demo.org",
  password: "123456"
)

user3 = User.create!(
  email: "kanazawa-community@demo.org",
  password: "123456"
)

puts "Creating users for donors..."

user4 = User.create!(
  email: "sam@donor.com",
  password: "123456"
)

user5 = User.create!(
  email: "hana@donor.com",
  password: "123456"
)

user6 = User.create!(
  email: "alice@abccorp.com",
  password: "123456"
)

puts "#{User.count} users created!"

puts "----------------------------------------------"

puts "Creating charities..."

charity1 = Charity.create!(
  user: user1,
  prefecture: "Tokyo",
  description: "Emergency shelter support for Single Mothers escaping from abuse (demo)",
  org_name: "Tokyo Single Mothers Shelter (DEMO)",
  region: "Kanto",
  shipping_address: "1-2-3 Demo, Shibuya-ku, Tokyo"
  )

puts "Charity #{charity1.org_name} created."

charity2 = Charity.create!(
  user: user2,
  prefecture: "Osaka",
  description: "Food support NPO for families that need support (demo)",
  org_name: "Osaka Food Support (DEMO)",
  region: "Kansai",
  shipping_address: "4-5-6 Demo, Osaka-shi, Osaka"
)

puts "Charity #{charity2.org_name} created."

charity3 = Charity.create!(
  user: user3,
  prefecture: "Ishikawa",
  description: "Community center for children who need community / food support (demo)",
  org_name: "Kanazawa Children’s Community Space (DEMO)",
  region: "Ishikawa",
  shipping_address: "7-8-9 Demo, Kanazawa, Ishikawa"
)

puts "Charity #{charity3.org_name} created."

puts "----------------------------------------------"

puts "Creating donors..."

donor1 = Donor.create!(
  user: user4,
  prefecture: "Tokyo",
  display_name: "Sam Samson",
  donor_type: "individual",
  region: "Kanto"
)

puts "Donor #{donor1.display_name} created."

donor2 = Donor.create!(
  user: user5,
  prefecture: "Osaka",
  display_name: "Hana Tanaka",
  donor_type: "individual",
  region: "Kansai"
)

puts "Donor #{donor2.display_name} created."

donor3 = Donor.create!(
  user: user6,
  prefecture: "Tokyo",
  display_name: "ABC Corp",
  donor_type: "company",
  region: "Kanto"
)

puts "Donor #{donor3.display_name} created."

puts "----------------------------------------------"

puts "Creating requests..."

request1 = Request.create!(
  category: "electronics",
  charity: charity1,
  prefecture: "Tokyo",
  condition: "Used - Good",
  description: "charger included",
  quantity_needed: 2,
  quantity_remaining: 2,
  region: "Kanto",
  status: "submitted",
  title: "Laptops",
  units: "units",
  urgency: "high"
)

puts "Created request for #{request1.quantity_needed} #{request1.title}."

request2 = Request.create!(
  category: "clothes",
  charity: charity1,
  prefecture: "Tokyo",
  condition: "Used - Good",
  description: "Clean, good condition",
  quantity_needed: 10,
  quantity_remaining: 10,
  region: "Kanto",
  status: "submitted",
  title: "Winter coats (adult)",
  units: "coats",
  urgency: "medium"
)

puts "Created request for #{request2.quantity_needed} #{request2.title}."

request3 = Request.create!(
  category: "clothes",
  charity: charity2,
  prefecture: "Osaka",
  condition: "Used - Good",
  description: "Good condition",
  quantity_needed: 15,
  quantity_remaining: 15,
  region: "Kansai",
  status: "submitted",
  title: "Kids shoes (sizes 18-22cm)",
  units: "pairs",
  urgency: "medium"
)

puts "Created request for #{request3.quantity_needed} #{request3.title}."

request4 = Request.create!(
  category: "necessities",
  charity: charity3,
  prefecture: "Ishikawa",
  condition: "New",
  description: "Sealed preferred",
  quantity_needed: 50,
  quantity_remaining: 50,
  region: "Ishikawa",
  status: "submitted",
  title: "Hygiene kits",
  units: "kits",
  urgency: "high"
)

puts "Created request for #{request4.quantity_needed} #{request4.title}."


request5 = Request.create!(
  category: "food",
  charity: charity2,
  prefecture: "Osaka",
  condition: "New",
  description: "Expiry 3+ months",
  quantity_needed: 20,
  quantity_remaining: 20,
  region: "Kansai",
  status: "submitted",
  title: "Rice (unopened)",
  units: "kg",
  urgency: "medium"
)

puts "Created request for #{request5.quantity_needed} #{request5.title}."

request6 = Request.create!(
  category: "clothes",
  charity: charity1,
  prefecture: "Tokyo",
  condition: "Used - Very Good",
  description: "New or like new",
  quantity_needed: 30,
  quantity_remaining: 30,
  region: "Kanto",
  status: "submitted",
  title: "Towels",
  units: "units",
  urgency: "medium"
)

puts "Created request for #{request6.quantity_needed} #{request6.title}."

request7 = Request.create!(
  category: "clothes",
  charity: charity3,
  prefecture: "Ishikawa",
  condition: "New",
  description: "Clean/ New",
  quantity_needed: 20,
  quantity_remaining: 20,
  region: "Ishikawa",
  status: "submitted",
  title: "Blankets",
  units: "units",
  urgency: "high"
)

puts "Created request for #{request7.quantity_needed} #{request7.title}."

request8 = Request.create!(
  category: "stationery",
  charity: charity2,
  prefecture: "Osaka",
  condition: "New",
  description: "",
  quantity_needed: 40,
  quantity_remaining: 40,
  region: "Kansai",
  status: "submitted",
  title: "Stationery sets",
  units: "sets",
  urgency: "medium"
)

puts "Created request for #{request8.quantity_needed} #{request8.title}."

request9 = Request.create!(
  category: "electronics",
  charity: charity1,
  prefecture: "Tokyo",
  condition: "Used - Good",
  description: "USB-C type",
  quantity_needed: 25,
  quantity_remaining: 25,
  region: "Kanto",
  status: "submitted",
  title: "Phone chargers",
  units: "units",
  urgency: "low"
)

puts "Created request for #{request9.quantity_needed} #{request9.title}."

request10 = Request.create!(
  category: "clothes",
  charity: charity3,
  prefecture: "Ishikawa",
  condition: "Used - Good",
  description: "Backpacks for kids",
  quantity_needed: 20,
  quantity_remaining: 20,
  region: "Ishikawa",
  status: "submitted",
  title: "Backpacks (kids)",
  units: "units",
  urgency: "medium"
)

puts "Created request for #{request10.quantity_needed} #{request10.title}."

puts "----------------------------------------------"

puts "Creating offers..."

offer1 = Offer.create!(
  can_ship_by: Date.today + 7.days,
  condition: "Used - Good",
  donor: donor1,
  message: "Can ship next week",
  quantity_offered: 2,
  request: request1,
  status: "submitted",
  tracking_number: ""
)

puts "Created offer for #{offer1.quantity_offered} for #{offer1.request.title} by #{offer1.donor.display_name}"

offer2 = Offer.create!(
  can_ship_by: Date.today,
  condition: "New",
  donor: donor3,
  message: "",
  quantity_offered: 20,
  request: request4,
  status: "accepted",
  tracking_number: ""
)

puts "Created offer for #{offer2.quantity_offered} for #{offer2.request.title} by #{offer2.donor.display_name}"

offer3 = Offer.create!(
  can_ship_by: Date.today,
  condition: "Used - Poor",
  donor: donor1,
  message: "",
  quantity_offered: 5,
  request: request2,
  status: "declined",
  tracking_number: ""
)

puts "Created offer for #{offer3.quantity_offered} for #{offer3.request.title} by #{offer3.donor.display_name}"

offer4 = Offer.create!(
  can_ship_by: Date.yesterday,
  condition: "New",
  donor: donor3,
  message: "",
  quantity_offered: 10,
  request: request7,
  status: "shipped",
  tracking_number: "EE123456789JP"
)

puts "Created offer for #{offer4.quantity_offered} for #{offer4.request.title} by #{offer4.donor.display_name}"

offer5 = Offer.create!(
  can_ship_by: Date.today - 7.days,
  condition: "New",
  donor: donor2,
  message: "",
  quantity_offered: 40,
  request: request8,
  status: "received",
  tracking_number: ""
)

puts "Created offer for #{offer5.quantity_offered} for #{offer5.request.title} by #{offer5.donor.display_name}"

puts "Seed finished!"
