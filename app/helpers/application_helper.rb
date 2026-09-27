module ApplicationHelper
  def dynamic_dashboard_path(user)
    return root_path unless user

    # Check enum role and return the correct path
    case user.role
    when 'admin'
      admins_dashboard_path
    when 'charity'
      charities_dashboard_path
    when 'donor'
      donors_dashboard_path
    else
      root_path
    end
  end

  # Standard way to show a quantity, e.g. "19x"
  def quantity_label(quantity)
    "#{quantity}x"
  end

  # Standard way to show where a charity or donor is, e.g. "Kanto - Tokyo"
  def location_label(record)
    parts = []
    parts << t("regions.#{record.region}") if record.region.present?
    parts << t("prefectures.#{record.prefecture}") if record.prefecture.present?
    parts.join(" - ")
  end

  def charity_location(charity)
    location_label(charity)
  end

  def prefecture_options_by_region
    Request::REGIONS_AND_PREFECTURES.transform_values do |prefectures|
      prefectures.map { |p| [t("prefectures.#{p}"), p] }
    end
  end

  def offer_ship_date(offer)
    if offer.shipped_or_later?
      { label: t("statuses.donor.arriving"), date: offer.estimated_arrival } if offer.estimated_arrival
    elsif offer.can_ship_by
      { label: t("offers.can_ship_by"), date: offer.can_ship_by }
    end
  end

  # Icon shown before a charity's name
  def charity_icon
    tag.i(class: "fa-solid fa-hand-holding-heart fa-fw me-1", title: t("navigation.charity"))
  end

  # Icon shown before a donor's name: building for companies, person for individuals
  def donor_icon(donor)
    icon = donor.donor_type == "company" ? "fa-building" : "fa-user"
    tag.i(class: "fa-solid #{icon} fa-fw me-1", title: t("donors.types.#{donor.donor_type.presence || 'individual'}"))
  end

  # Plain status badges, used where admins need to see the raw state
  def offer_status_badge(offer)
    tag.span(t("statuses.donor.#{offer.status}", default: offer.status.humanize),
             class: "badge rounded-pill text-bg-secondary km--text-pill text-nowrap")
  end

  def request_status_badge(request)
    tag.span(t("statuses.requests.#{request.status}", default: request.status.humanize),
             class: "badge rounded-pill text-bg-secondary km--text-pill text-nowrap")
  end

  # Standard way to show an item with its quantity, e.g. "19x Rice"
  def title_with_quantity(title, quantity)
    "#{quantity_label(quantity)} #{title}"
  end
end
