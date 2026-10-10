module RequestsHelper
  # One-line summary of the active request filters, shown when the filter card is collapsed
  def request_filter_summary
    filters = request_filter_labels
    filters.any? ? t("navigation.filtering_to", filters: filters.join(" · ")) : t("navigation.showing_all_requests")
  end

  # Whether to offer Reset on the collapsed filter header
  def request_filters_active?
    request_filter_labels.any?
  end

  private

  def request_filter_labels
    filters = []
    filters << "“#{params[:query]}”" if params[:query].present?
    filters << t("prefectures.#{params[:prefecture]}") if params[:prefecture].present?
    categories = Array(params[:category]).compact_blank
    filters << categories.map { |category| t("categories.#{category}") }.join(", ") if categories.any?
    filters << t("navigation.no_offers_yet") if params[:no_offers] == "1"
    filters << t("shipping.accepts_shipping") if params[:shipping] == "1"
    filters << t("shipping.accepts_drop_off") if params[:drop_off] == "1"
    filters
  end
end
