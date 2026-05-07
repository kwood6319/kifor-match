AdminDashboardPolicy = Struct.new(:user, :dashboard) do
  def show?
    user.admin?
  end
end
