module OffersHelper
  DONATION_RULES_IMAGES = {
    "books" => "books.png",
    "clothes" => "clothes.png",
    "electronics" => "electronics.png",
    "food" => "food.png",
    "home_goods" => "furniture.png",
    "hygiene" => "hygiene.png",
    "kids" => "toys.png",
    "stationery" => "stationery.png"
  }.freeze

  # Returns the donation rules image path for the request's first category, or nil if none applies
  def donation_rules_image(request)
    file = DONATION_RULES_IMAGES[request.category&.first]
    "donation_rules/#{file}" if file
  end
end
