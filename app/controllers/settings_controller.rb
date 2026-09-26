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
        redirect_to settings_path(tab: params[:tab].presence), notice: t("settings.profile_updated")
      else
        @donor = current_user.donor
        @has_shipped_offers = charity_has_shipped_offers?
        render :show, status: :unprocessable_entity
      end
    elsif current_user.charity?
      if current_user.charity.update(charity_params)
        redirect_to settings_path(tab: params[:tab].presence), notice: t("settings.profile_updated")
      else
        @charity = current_user.charity
        @has_shipped_offers = charity_has_shipped_offers?
        render :show, status: :unprocessable_entity
      end
    else
      redirect_to settings_path
    end
  end

  def update_email
    if current_user.update(email_params)
      redirect_to settings_path, notice: t("settings.email_updated")
    else
      render_account_errors(:email)
    end
  end

  # Unlike the other sections, a password change needs the current password.
  def update_password
    if current_user.update_with_password(password_params)
      bypass_sign_in(current_user)
      redirect_to settings_path, notice: t("settings.password_updated")
    else
      render_account_errors(:password)
    end
  end

  def update_locale
    if current_user.update(locale_params)
      session.delete(:locale)
      # Confirm in the newly chosen language, not the one this request ran in
      new_locale = current_user.locale
      redirect_to settings_path(locale: new_locale),
                  notice: t("settings.language_updated", locale: new_locale)
    else
      @donor = current_user.donor
      @charity = current_user.charity
      render :show, status: :unprocessable_entity
    end
  end

  def deactivate
    current_user.update!(active: false)
    sign_out(current_user)
    redirect_to root_path, notice: t("settings.account_deactivated")
  end

  private

  # Re-renders the page on the Email & Password tab with the failed section open.
  def render_account_errors(section)
    @donor = current_user.donor
    @charity = current_user.charity
    @has_shipped_offers = charity_has_shipped_offers?
    @account_errors = current_user.errors
    @open_account_section = section
    current_user.restore_attributes([:email]) if section == :email
    render :show, status: :unprocessable_entity
  end

  def email_params
    params.require(:user).permit(:email)
  end

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

  def charity_has_shipped_offers?
    return false unless current_user.charity?

    Offer.joins(:request)
         .where(requests: { charity_id: current_charity.id }, status: "shipped")
         .exists?
  end
end
