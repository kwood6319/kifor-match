module AdminFiltersHelper
  # One-line summary of the active charity/donor filters, shown when the filter card is collapsed
  def admin_filter_summary(showing_all_key)
    filters = admin_filter_labels
    filters.any? ? t("navigation.filtering_to", filters: filters.join(" · ")) : t(showing_all_key)
  end

  # Whether to offer Reset on the collapsed filter header
  def admin_filters_active?
    admin_filter_labels.any?
  end

  private

  def admin_filter_labels
    filters = []
    filters << "“#{params[:query]}”" if params[:query].present?
    filters << t("regions.#{params[:region]}") if params[:region].present?
    filters << t("navigation.approved_only") if params[:approved_only] == "1"
    filters << t("navigation.unapproved_only") if params[:unapproved_only] == "1"
    filters
  end
end
