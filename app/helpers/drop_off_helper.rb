module DropOffHelper
  # Drop-off hours as display lines, e.g. ["Mon–Fri 9:00–17:00", "Sat 10:00–12:00"].
  # Takes a charity's windows (live) or an offer's delivery_drop_off_windows (as approved).
  # Consecutive days with the same hours share a line; a closed day breaks the run.
  def drop_off_hours_lines(windows)
    # Skips any placeholders drop_off_week built on this page
    windows = windows.reject(&:placeholder).index_by(&:day_of_week)
    hours_runs(windows).map { |run| "#{day_range(run[:days])} #{run[:hours].join('–')}" }
  end

  # The seven rows for the settings form, Monday first: saved days as they are,
  # closed days as unsaved placeholders (unticked) with default hours to start from.
  def drop_off_week(charity)
    DropOffWindow::WEEK_ORDER.map do |day|
      charity.drop_off_windows.find { |window| window.day_of_week == day } ||
        charity.drop_off_windows.build(day_of_week: day, opens_at: "09:00", closes_at: "17:00", placeholder: true)
    end
  end

  # With no hours on record there's nothing to limit to, so offer daytime slots
  DEFAULT_DROP_OFF_HOURS = %w[07:00 21:00].freeze

  # 30-minute drop-off times on `date` within that day's hours, e.g. ["9:00", "9:30", ... "16:30"]
  # as [label, value] pairs. Empty when the charity is closed that day (or no date yet).
  def drop_off_time_options(windows, date)
    return [] unless date

    window = if windows.empty?
               DropOffWindow.new(opens_at: DEFAULT_DROP_OFF_HOURS.first, closes_at: DEFAULT_DROP_OFF_HOURS.last)
             else
               windows.find { |w| w.day_of_week == date.wday }
             end
    return [] unless window

    opens, closes = [window.opens_at, window.closes_at].map { |time| (time.hour * 60) + time.min }
    first = (opens / 30.0).ceil * 30 # first :00 / :30 at or after opening (e.g. 9:15 -> 9:30)
    (first...closes).step(30).map do |minutes|
      value = format("%<hour>02d:%<minute>02d", hour: minutes / 60, minute: minutes % 60)
      [value.delete_prefix("0"), value]
    end
  end

  # Default planned drop-off: the next day (from tomorrow) the charity is open. With no hours on
  # record, the next weekday. Looks two weeks ahead, so a charity always open on some day is found.
  def next_drop_off_date(windows)
    open_days = windows.empty? ? (1..5).to_a : windows.map(&:day_of_week)
    (1..14).map { |offset| Date.current + offset }.find { |date| open_days.include?(date.wday) }
  end

  def day_name(wday)
    t("date.abbr_day_names")[wday]
  end

  private

  # [{ days: [1, 2, 3], hours: ["9:00", "17:00"] }, ...] in week order
  def hours_runs(windows)
    DropOffWindow::WEEK_ORDER.each_with_object([]) do |day, runs|
      window = windows[day]
      next runs << nil unless window

      hours = [window.opens_at, window.closes_at].map { |time| time.strftime("%-H:%M") }
      runs.last && runs.last[:hours] == hours ? runs.last[:days] << day : runs << { days: [day], hours: hours }
    end.compact
  end

  def day_range(days)
    days.one? ? day_name(days.first) : "#{day_name(days.first)}–#{day_name(days.last)}"
  end
end
