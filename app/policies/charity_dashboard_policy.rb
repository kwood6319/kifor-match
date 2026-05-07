CharityDashboardPolicy = Struct.new(:user, :dashboard) do
  def show?
    user.charity?
  end
end
