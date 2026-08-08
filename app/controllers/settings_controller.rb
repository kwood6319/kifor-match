class SettingsController < ApplicationController
  before_action :authenticate_user!
  skip_after_action :verify_authorized

  def show
    @donor = current_user.donor
    @charity = current_user.charity
  end

  def update
    if current_user.donor?
      if current_user.donor.update(donor_params)
        redirect_to settings_path, notice: t("settings.profile_updated")
      else
        @donor = current_user.donor
        render :show, status: :unprocessable_entity
      end
    elsif current_user.charity?
      if current_user.charity.update(charity_params)
        redirect_to settings_path, notice: t("settings.profile_updated")
      else
        @charity = current_user.charity
        render :show, status: :unprocessable_entity
      end
    else
      redirect_to settings_path
    end
  end

  def update_password
    if password_params[:password].blank? && password_params[:password_confirmation].blank?
      current_user.errors.add(:password, :blank)
      @donor = current_user.donor
      @charity = current_user.charity
      @password_errors = current_user.errors
      render :show, status: :unprocessable_entity
      return
    end

    if current_user.update_with_password(password_params)
      bypass_sign_in(current_user)
      redirect_to settings_path, notice: t("settings.password_updated")
    else
      @donor = current_user.donor
      @charity = current_user.charity
      @password_errors = current_user.errors
      render :show, status: :unprocessable_entity
    end
  end

  def update_locale
    if current_user.upadte(locale_params)
      redirect_to settings_path, notice: t("settings.language_updated")
    else
      @donor = current_user.donor
      @charity = current_user.charity
      render :show, status: :unprocessable_entity
    end
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

  def locale_params
    params.require(:user).permit(:locale)
  end
end
