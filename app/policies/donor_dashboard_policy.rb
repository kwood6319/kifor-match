DonorDashboardPolicy = Struct.new(:user, :dashboard) do
  def show?
    user.donor?
  end
end
