require "open-uri"

puts "Cleaning database..."

Offer.destroy_all
Request.destroy_all
Donor.destroy_all
Charity.destroy_all
User.destroy_all

puts "Database clean :)! #{Donor.count} donors, #{Charity.count} charities, #{User.count} users."
puts "#{Request.count} requests, #{Offer.count} offers."

puts "----------------------------------------------"

puts "Creating users..."

USERS = [
  { key: :user1, role: 1, email: "tokyo-shelter@demo.org" },
  { key: :user2, role: 1, email: "osaka-food@demo.org" },
  { key: :user3, role: 1, email: "kanazawa-community@demo.org" },
  { key: :user4, role: 0, email: "sam@donor.com" },
  { key: :user5, role: 0, email: "hana@donor.com" },
  { key: :user6, role: 0, email: "alice@abccorp.com" },
  { key: :user7, role: 2, email: "francis@admin" },
  { key: :user8, role: 0, email: "lewagon@donor.com" },
  { key: :user9, role: 1, email: "youmewe@charity.com" },
  { key: :user10, role: 1, email: "refugeechildren@charity.com" },
  { key: :user11, role: 0, email: "childrens@donor.com" }
].freeze

users = USERS.each_with_object({}) do |attrs, hash|
  hash[attrs[:key]] = User.create!(role: attrs[:role], email: attrs[:email], password: "123456")
end

puts "#{User.count} users created!"

puts "----------------------------------------------"

puts "Creating charities..."

CHARITIES = [
  { key: :charity1, user: :user1, prefecture: "Tokyo", region: "Kanto",
    org_name: "Tokyo Single Mothers Shelter (DEMO)",
    description: "Emergency shelter support for Single Mothers escaping from abuse (demo)",
    shipping_address: "1-2-3 Demo, Shibuya-ku, Tokyo" },
  { key: :charity2, user: :user2, prefecture: "Osaka", region: "Kansai",
    org_name: "Osaka Food Support (DEMO)",
    description: "Food support NPO for families that need support (demo)",
    shipping_address: "4-5-6 Demo, Osaka-shi, Osaka" },
  { key: :charity3, user: :user3, prefecture: "Ishikawa", region: "Chubu",
    org_name: "Kanazawa Children's Community Space (DEMO)",
    description: "Community center for children who need community / food support (demo)",
    shipping_address: "7-8-9 Demo, Kanazawa, Ishikawa" },
  { key: :charity4, user: :user9, prefecture: "Tokyo", region: "Kanto",
    org_name: "YouWeMe",
    description: "Looking for laptops",
    shipping_address: "123 Tokyo" },
  { key: :charity5, user: :user10, prefecture: "Tokyo", region: "Kanto",
    org_name: "Refugee Children",
    description: "A charity supporting refugee children",
    shipping_address: "456 Tokyo" }
].freeze

charities = CHARITIES.each_with_object({}) do |attrs, hash|
  hash[attrs[:key]] = Charity.create!(
    user: users.fetch(attrs[:user]),
    prefecture: attrs[:prefecture],
    region: attrs[:region],
    org_name: attrs[:org_name],
    description: attrs[:description],
    shipping_address: attrs[:shipping_address]
  )
  puts "Charity #{attrs[:org_name]} created."
end

puts "#{Charity.count} charities created!"

puts "----------------------------------------------"

puts "Creating donors..."

DONORS = [
  { key: :donor1, user: :user4,  prefecture: "Tokyo", region: "Kanto",  display_name: "Sam Samson",     donor_type: "individual" },
  { key: :donor2, user: :user5,  prefecture: "Osaka", region: "Kansai", display_name: "Hana Tanaka",     donor_type: "individual" },
  { key: :donor3, user: :user6,  prefecture: "Tokyo", region: "Kanto",  display_name: "ABC Corp",        donor_type: "company" },
  { key: :donor4, user: :user8,  prefecture: "Tokyo", region: "Kanto",  display_name: "Le Wagon Tokyo",  donor_type: "company" },
  { key: :donor5, user: :user11, prefecture: "Tokyo", region: "Kanto",  display_name: "Toy Donor",       donor_type: "individual" }
].freeze

donors = DONORS.each_with_object({}) do |attrs, hash|
  hash[attrs[:key]] = Donor.create!(
    user: users.fetch(attrs[:user]),
    prefecture: attrs[:prefecture],
    region: attrs[:prefecture],
    display_name: attrs[:display_name],
    donor_type: attrs[:donor_type]
  )
  puts "Donor #{attrs[:display_name]} created."
end

puts "#{Donor.count} donors created!"

puts "----------------------------------------------"

puts "Creating requests..."

REQUESTS = [
  { key: :request1,  charity: :charity1, category: ["electronics"], subcategory: ["laptops"],
    title: "Laptops", condition: "used_good", description: "charger included",
    quantity_needed: 2, urgency: "high" },
  { key: :request2,  charity: :charity1, category: ["clothes"], subcategory: %w[mens womens],
    title: "Winter coats (adult)", condition: "used_good", description: "Clean, good condition",
    quantity_needed: 10, urgency: "medium" },
  { key: :request3,  charity: :charity2, category: ["clothes"], subcategory: %w[childrens shoes],
    title: "Kids shoes (sizes 18-22cm)", condition: "used_good", description: "Good condition",
    quantity_needed: 15, urgency: "medium" },
  { key: :request4,  charity: :charity3, category: ["hygiene"], subcategory: [],
    title: "Hygiene kits", condition: "new", description: "Sealed preferred",
    quantity_needed: 50, urgency: "high" },
  { key: :request5,  charity: :charity2, category: ["food"], subcategory: ["nonperishable"],
    title: "Rice (unopened)", condition: "new", description: "Expiry 3+ months",
    quantity_needed: 20, urgency: "medium" },
  { key: :request6,  charity: :charity1, category: ["home_goods"], subcategory: ["bedding"],
    title: "Towels", condition: "used_very_good", description: "Bathing towels",
    quantity_needed: 30, urgency: "medium" },
  { key: :request7,  charity: :charity3, category: ["home_goods"], subcategory: ["bedding"],
    title: "Blankets", condition: "new", description: "Clean/ New",
    quantity_needed: 20, urgency: "high" },
  { key: :request8,  charity: :charity2, category: ["stationery"], subcategory: [],
    title: "Stationery sets", condition: "new", description: "Full sets",
    quantity_needed: 40, urgency: "medium" },
  { key: :request9,  charity: :charity1, category: ["electronics"], subcategory: %w[phones other],
    title: "Phone chargers", condition: "used_good", description: "USB-C type",
    quantity_needed: 25, urgency: "low" },
  { key: :request10, charity: :charity3, category: ["kids"], subcategory: ["school_supplies"],
    title: "Backpacks (kids)", condition: "used_good", description: "Backpacks for kids",
    quantity_needed: 20, urgency: "medium" },
  { key: :request11, charity: :charity4, category: ["electronics"], subcategory: ["laptops"],
    title: "Laptops", condition: "used_good", description: "Laptops needed",
    quantity_needed: 2, urgency: "high" },
  { key: :request12, charity: :charity2, category: ["kids"], subcategory: ["other"],
    title: "Baby diapers", condition: "new", description: "Disposable diapers, mixed sizes welcome",
    quantity_needed: 25, urgency: "urgent" },
  { key: :request13, charity: :charity4, category: ["food"], subcategory: ["canned"],
    title: "Canned soup", condition: "new", description: "Unopened canned soup, expiry 3+ months",
    quantity_needed: 40, urgency: "high" },
  { key: :request14, charity: :charity3, category: ["hygiene"], subcategory: [],
    title: "Dental hygiene kits", condition: "new", description: "Toothbrush + toothpaste bundles preferred",
    quantity_needed: 30, urgency: "medium" },
  { key: :request15, charity: :charity1, category: ["stationery"], subcategory: [],
    title: "School supply sets", condition: "new", description: "Pens, pencils, erasers included",
    quantity_needed: 20, urgency: "medium" },
  { key: :request16, charity: :charity2, category: ["home_goods"], subcategory: [],
    title: "Cleaning supplies", condition: "new", description: "Kitchen and bathroom cleaner",
    quantity_needed: 15, urgency: "high" },
  { key: :request17, charity: :charity3, category: ["home_goods"], subcategory: ["bedding"],
    title: "Winter blankets", condition: "used_good", description: "Warm blankets for winter shelter",
    quantity_needed: 18, urgency: "urgent" },
  { key: :request18, charity: :charity4, category: ["clothes"], subcategory: %w[childrens shoes],
    title: "Kids rain boots", condition: "used_like_new", description: "Children's rain boots, sizes mixed",
    quantity_needed: 12, urgency: "medium" },
  { key: :request19, charity: :charity1, category: ["electronics"], subcategory: ["other"],
    title: "Kitchen appliances", condition: "used_good", description: "Rice cookers or electric kettles welcome",
    quantity_needed: 6, urgency: "low" },
  { key: :request20, charity: :charity2, category: ["food"], subcategory: ["other"],
    title: "Milk cartons", condition: "new", description: "Shelf-stable milk cartons",
    quantity_needed: 24, urgency: "medium", status: "fulfilled" },
  { key: :request21, charity: :charity4, category: ["kids"], subcategory: ["school_supplies"],
    title: "School backpacks", condition: "used_good", description: "Reusable backpacks for school-age children",
    quantity_needed: 14, urgency: "medium" }
].freeze

requests = REQUESTS.each_with_object({}) do |attrs, hash|
  request = Request.create!(
    charity: charities.fetch(attrs[:charity]),
    category: attrs[:category],
    subcategory: attrs[:subcategory],
    title: attrs[:title],
    condition: attrs[:condition],
    description: attrs[:description],
    quantity_needed: attrs[:quantity_needed],
    quantity_remaining: attrs[:quantity_remaining],
    urgency: attrs[:urgency],
    status: attrs[:status] || "active"
  )
  hash[attrs[:key]] = request
  puts "Created request for #{request.quantity_needed} #{request.title}."
end

puts "----------------------------------------------"

puts "Creating offers..."

# A handful of stable placeholder images (Picsum's fixed-seed URLs return the
# same image every time, so seeding is reproducible run to run).
DUMMY_PHOTO_URLS = [
  "https://picsum.photos/seed/kifor1/600/400",
  "https://picsum.photos/seed/kifor2/600/400",
  "https://picsum.photos/seed/kifor3/600/400",
  "https://picsum.photos/seed/kifor4/600/400"
].freeze

def attach_dummy_photo(offer, url, filename)
  file = URI.open(url)
  offer.photo.attach(io: file, filename: filename, content_type: "image/jpeg")
rescue OpenURI::HTTPError, SocketError => e
  puts "  (could not fetch dummy photo from #{url}: #{e.message})"
end

OFFERS = [
  { key: :offer1a, request: :request1,  donor: :donor1, condition: "used_good",      quantity_offered: 2,  status: "submitted", can_ship_by: 7.days.from_now.to_date,  message: "Can ship next week" },
  { key: :offer1b, request: :request1,  donor: :donor2, condition: "used_like_new",  quantity_offered: 1,  status: "submitted", can_ship_by: 7.days.from_now.to_date,  message: "Can ship next week" },
  { key: :offer2,  request: :request4,  donor: :donor3, condition: "new",            quantity_offered: 20, status: "approved",  can_ship_by: Date.today },
  { key: :offer3,  request: :request2,  donor: :donor1, condition: "used_good",      quantity_offered: 5,  status: "rejected",  can_ship_by: Date.today },
  { key: :offer4,  request: :request7,  donor: :donor3, condition: "new",            quantity_offered: 10, status: "shipped",   can_ship_by: Date.yesterday,          tracking_number: "EE123456789JP" },
  { key: :offer5,  request: :request8,  donor: :donor2, condition: "new",            quantity_offered: 40, status: "received",  can_ship_by: 7.days.ago.to_date },
  { key: :offer6,  request: :request11, donor: :donor4, condition: "used_like_new",  quantity_offered: 2,  status: "approved",  can_ship_by: 3.days.ago.to_date,       tracking_number: "XXXXXX", message: "Laptops like new" }
].freeze

OFFERS.each_with_index do |attrs, index|
  offer = Offer.new(
    request: requests.fetch(attrs[:request]),
    donor: donors.fetch(attrs[:donor]),
    condition: attrs[:condition],
    quantity_offered: attrs[:quantity_offered],
    status: attrs[:status],
    can_ship_by: attrs[:can_ship_by],
    message: attrs[:message] || "",
    tracking_number: attrs[:tracking_number] || ""
  )

  filename = "#{attrs[:key]}-item.jpg"
  attach_dummy_photo(offer, DUMMY_PHOTO_URLS[index % DUMMY_PHOTO_URLS.size], filename)

  offer.save!

  puts "Created offer for #{offer.quantity_offered} for #{offer.request.title} by #{offer.donor.display_name}"
end

puts "Seed finished! おつかれ"
