module OffersHelper
  DONATION_RULES_IMAGES = {
    "books" => "books.png",
    "clothes" => "clothes.png",
    "electronics" => "electronics.png",
    "food" => "food.png",
    "home_goods" => "general.jpg",
    "hygiene" => "hygiene.png",
    "kids" => "general.jpg",
    "stationery" => "stationery.png",
    "other_items" => "general.jpg"
  }.freeze

  # Japanese versions of the images above, keyed by the English file name
  DONATION_RULES_IMAGES_JA = {
    "books.png" => "books.ja.jpg",
    "clothes.png" => "clothes.ja.jpg",
    "electronics.png" => "electronics.ja.jpg",
    "food.png" => "food.ja.jpg",
    "general.jpg" => "general.ja.jpg",
    "hygiene.png" => "hygiene.ja.jpg",
    "stationery.png" => "stationery.ja.jpg"
  }.freeze

  # Returns the donation rules image path for the request's first category in the current locale,
  # or nil if none applies. Falls back to the English image when there is no translation.
  def donation_rules_image(request)
    file = DONATION_RULES_IMAGES[request.category&.first]
    return unless file

    file = DONATION_RULES_IMAGES_JA.fetch(file, file) if I18n.locale == :ja
    "donation_rules/#{file}"
  end
end
