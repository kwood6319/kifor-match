module RequestsHelper
  # One-line summary of the active request filters, shown when the filter card is collapsed
  def request_filter_summary
    filters = []
    filters << "“#{params[:query]}”" if params[:query].present?
    filters << t("prefectures.#{params[:prefecture]}") if params[:prefecture].present?
    categories = Array(params[:category]).compact_blank
    filters << categories.map { |category| t("categories.#{category}") }.join(", ") if categories.any?
    filters << t("navigation.no_offers_yet") if params[:no_offers] == "1"

    filters.any? ? t("navigation.filtering_to", filters: filters.join(" · ")) : t("navigation.showing_all_requests")
  end
end
