module FeedbackTags
  TAGS = [
    # slug            label                                   group      categories
    { slug: :as_described, label: "Item as described",              group: :positive, categories: :all },
    { slug: :functioning,  label: "Functioning",                    group: :positive, categories: :all },
    { slug: :acceptable,   label: "Acceptable",                     group: :positive, categories: :all },
    { slug: :complete,     label: "Complete — everything included", group: :positive, categories: :all },

    { slug: :torn,         label: "Torn",                       group: :negative, categories: :all },
    { slug: :broken,       label: "Broken",                     group: :negative, categories: :all },
    { slug: :wrong_sizes,  label: "Wrong sizes",                group: :negative, categories: :all },
    { slug: :dirty,        label: "Dirty",                      group: :negative, categories: :all },
    { slug: :incomplete,   label: "Incomplete — items missing", group: :negative, categories: :all },
    { slug: :scratches,    label: "Scratches",                  group: :negative, categories: :all },
    { slug: :smells,       label: "Smells",                     group: :negative, categories: :all },
    { slug: :stained,      label: "Stained",                    group: :negative, categories: :all },

    { slug: :mold, label: "Mold or insects", group: :critical, categories: :all },
    { slug: :dangerous, label: "Dangerous — exposed cables or broken glass", group: :critical, categories: :all },
    { slug: :strange_liquid, label: "Strange liquids or markings", group: :critical, categories: :all },
    { slug: :food_expired, label: "Food — expired", group: :critical, categories: %w[food] },
    { slug: :food_opened, label: "Food — opened", group: :critical, categories: %w[food] }
  ].freeze

  GROUPS = %i[positive negative critical].freeze

  def self.for(categories)
    categories = Array(categories)
    TAGS.select { |t| t[:categories] == :all || t[:categories].intersect?(categories) }
  end

  def self.grouped_for(categories)
    self.for(categories).group_by { |t| t[:group] }
  end
end
