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
end
