module NavigationHelper
  def primary_nav_items(user)
    return [] unless user

    items = [{ label: t("navigation.dashboard"), path: dynamic_dashboard_path(user) }]

    items << if user.admin?
               [{ label: t("navigation.charities"), path: charities_path },
                { label: t("navigation.donors"), path: donors_path }]
             elsif user.donor?
               [{ label: t("navigation.requests"), path: requests_path }]
             else
               []
             end

    items.flatten
  end
end
# KT To do: add unit tests for helper methods
