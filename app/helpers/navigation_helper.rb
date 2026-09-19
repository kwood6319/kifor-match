module NavigationHelper
  def primary_nav_items(user)
    return [] unless user

    [{ label: t("navigation.dashboard"), path: dynamic_dashboard_path(user) }, *role_nav_items(user)]
  end

  private

  def role_nav_items(user)
    if user.admin?
      [{ label: t("navigation.charities"), path: charities_path },
       { label: t("navigation.donors"), path: donors_path }]
    elsif user.donor?
      [{ label: t("navigation.requests"), path: requests_path }]
    elsif user.charity?
      [{ label: t("navigation.history"), path: charities_archived_requests_path }]
    else
      []
    end
  end
end
# KT To do: add unit tests for helper methods
