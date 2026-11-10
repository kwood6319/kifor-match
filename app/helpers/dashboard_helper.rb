# app/helpers/dashboard_helper.rb
module DashboardHelper
  def time_ago_badge(time)
    seconds = (Time.current - time).to_i

    if seconds < 1.hour
      minutes = seconds / 60
      t("dashboard.minutes_ago", count: minutes)
    elsif seconds < 1.day
      hours = seconds / 1.hour
      t("dashboard.hours_ago", count: hours)
    elsif seconds < 7.days
      days = seconds / 1.day
      t("dashboard.days_ago", count: days)
    else
      t("dashboard.seven_plus_days_ago")
    end
  end

  # Small counter on a tracker tab so waiting offers are noticed from any tab
  def tracker_tab_count(offers)
    count = offers.size
    return if count.zero?

    tag.span(count, class: "badge rounded-pill km--tab-count")
  end
end
