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

  # An address as the boxes of a Japanese shipping slip (送り状), in slip order and always in
  # Japanese, since that's how the label is written: [[label, value], ...].
  # The name falls back to the charity's name, since that's who the parcel is for.
  def shipping_label_fields(address)
    name = address.recipient_name.presence || address.addressable.try(:org_name)
    [
      [t("addresses.label.postal_code"), "〒#{address.formatted_postal_code}"],
      [t("addresses.label.address"), address.label_address],
      [t("addresses.label.name"), name]
    ].select { |_label, value| value.present? }
  end

  def prefecture_options_by_region
    Request::REGIONS_AND_PREFECTURES.transform_values do |prefectures|
      prefectures.map { |p| [t("prefectures.#{p}"), p] }
    end
  end

  def offer_ship_date(offer)
    if offer.shipped_or_later?
      if offer.estimated_arrival
        label = offer.drop_off? ? t("drop_off.planned_date") : t("statuses.donor.arriving")
        { label: label, date: offer.estimated_arrival, time: offer_time_label(offer), with_day: offer.drop_off? }
      end
    elsif offer.can_ship_by
      { label: t("offers.can_ship_by"), date: offer.can_ship_by }
    end
  end

  # e.g. "Oct 26 · 14:00-16:00" when shipping, "Tue, Oct 13 · 10:00" for a planned drop-off.
  # Drop-offs include the weekday (10月13日(火)): people remember the day better than the date.
  def ship_date_text(ship_date)
    text = l(ship_date[:date], format: ship_date[:with_day] ? :short_with_day : :short)
    ship_date[:time].present? ? "#{text} · #{ship_date[:time]}" : text
  end

  def arrival_text(offer)
    ship_date_text(date: offer.estimated_arrival, time: offer_time_label(offer), with_day: offer.drop_off?)
  end

  # Drop-off: the planned time ("10:00"); shipping: the courier window ("14:00-16:00"), if any
  def offer_time_label(offer)
    if offer.drop_off?
      offer.drop_off_time&.strftime("%-H:%M")
    elsif offer.estimated_arrival_time.present?
      t("arrival_time_slots.#{offer.estimated_arrival_time}")
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

  # Plain status badges, used where admins need to see the raw state.
  # align-self-start stops a flex column (like .km--card) stretching them full width.
  def offer_status_badge(offer)
    tag.span(t("statuses.donor.#{offer.status}", default: offer.status.humanize),
             class: "badge rounded-pill text-bg-secondary km--text-pill text-nowrap align-self-start")
  end

  def request_status_badge(request)
    tag.span(t("statuses.requests.#{request.status}", default: request.status.humanize),
             class: "badge rounded-pill text-bg-secondary km--text-pill text-nowrap align-self-start")
  end

  # Standard way to show an item with its quantity, e.g. "19x Rice"
  def title_with_quantity(title, quantity)
    "#{quantity_label(quantity)} #{title}"
  end
end
