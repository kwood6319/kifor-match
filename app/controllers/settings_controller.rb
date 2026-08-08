class SettingsController < ApplicationController
  before_action :authenticate_user!
  skip_after_action :verify_authorized

  def show
    @donor = current_user.donor
    @charity = current_user.charity
    @has_shipped_offers = charity_has_shipped_offers?
  end

  def update
    if current_user.donor?
      if current_user.donor.update(donor_params)
        redirect_to settings_path, notice: t("settings.profile_updated")
      else
        @donor = current_user.donor
        @has_shipped_offers = charity_has_shipped_offers?
        render :show, status: :unprocessable_entity
      end
    elsif current_user.charity?
      if current_user.charity.update(charity_params)
        redirect_to settings_path, notice: t("settings.profile_updated")
      else
        @charity = current_user.charity
        @has_shipped_offers = charity_has_shipped_offers?
        render :show, status: :unprocessable_entity
      end
    else
      redirect_to settings_path
    end
  end

  def update_account
    if current_user.update_with_password(account_params)
      bypass_sign_in(current_user)
      redirect_to settings_path, notice: t("settings.account_updated")
    else
      @donor = current_user.donor
      @charity = current_user.charity
      @has_shipped_offers = charity_has_shipped_offers?
      @account_errors = current_user.errors
      render :show, status: :unprocessable_entity
    end
  end

  def deactivate
    current_user.update!(active: false)
    sign_out(current_user)
    redirect_to rooth_path, notice: t("settings.account_deactivated")
  end

  private

  def donor_params
    params.require(:donor).permit(:display_name, :donor_type, :region, :prefecture)
  end

  def charity_params
    params.require(:charity).permit(:org_name, :description, :region, :prefecture, :shipping_address)
  end

  def password_params
    params.require(:user).permit(:current_password, :password, :password_confirmation)
  end

  def charity_has_shipped_offers
    return false unless current_user.charity?

    Offer.joins(:request)
         .where(requests: { charity_id: current_charity.id }, status: "shipped"
         .exists?)
  end
end
