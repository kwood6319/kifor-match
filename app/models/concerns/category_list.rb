module CategoryList
  CATEGORIES = {
    "electronics" => {
      icons: %w[fa-desktop fa-headphones fa-camera],
      subcategories: %w[laptops phones headphones cameras tablets other]
    },
    "food" => {
      icons: %w[fa-utensils],
      subcategories: %w[canned fresh snacks baby_food nonperishable instant other]
    },
    "kids" => {
      icons: %w[fa-child-reaching],
      subcategories: %w[toys clothing school_supplies other]
    },
    "clothes" => {
      icons: %w[fa-shirt],
      subcategories: %w[mens womens childrens shoes other]
    },
    "hygiene" => {
      icons: %w[fa-pump-soap],
      subcategories: %w[]
    },
    "stationery" => {
      icons: %w[fa-pen],
      subcategories: %w[]
    },
    "home_goods" => {
      icons: %w[fa-couch],
      subcategories: %w[furniture kitchenware bedding towels other]
    },
    "books" => {
      icons: %w[fa-book],
      subcategories: %w[fiction nonfiction textbooks childrens other]
    },
    "other_items" => {
      icons: %w[fa-box],
      subcategories: %w[]
    },
    "cooking" => {
      icons: %w[],
      subcategories: %w[]
    },
    "cleaning" => {
      icons: %w[],
      subcategories: %w[]
    },
    "seasonal" => {
      icons: %w[],
      subcategories: %w[]
    },
    "necessities" => {
      icons: %w[],
      subcategories: %w[]
    }

  }.freeze

  def self.label_for(key)
    I18n.t("categories.#{key}")
  end

  def self.subcategory_label_for(category_key, subcategory_key)
    I18n.t("subcategories.#{category_key}.#{subcategory_key}")
  end

  def self.subcategories_for(category_key)
    CATEGORIES.dig(category_key, :subcategories) || []
  end
end
