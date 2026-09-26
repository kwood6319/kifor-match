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

  # Standard way to show where a charity is, e.g. "Kanto - Tokyo"
  def charity_location(charity)
    "#{t("regions.#{charity.region}")} - #{t("prefectures.#{charity.prefecture}")}"
  end

  # Standard way to show an item with its quantity, e.g. "19x Rice"
  def title_with_quantity(title, quantity)
    "#{quantity_label(quantity)} #{title}"
  end
end
