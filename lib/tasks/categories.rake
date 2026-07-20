namespace :categories do
  desc "Recalculate the top 8 categories by active request count"
  task recalculate_top: :environment do
    top = CategoryList.recalculate_top_categories!
    puts "Top categories updated: #{top.join(', ')}"
  end
end
