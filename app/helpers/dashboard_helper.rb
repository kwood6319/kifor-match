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
end
