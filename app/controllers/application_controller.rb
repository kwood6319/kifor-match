class ApplicationController < ActionController::Base
  before_action :set_locale
  before_action :authenticate_user!
  skip_before_action :authenticate_user!, if: :devise_controller?
  include Pundit::Authorization

  # Pundit: allow-list
  after_action :verify_authorized, except: :index, unless: :skip_pundit?
  after_action :verify_policy_scoped, only: :index, unless: :skip_pundit?

  # Uncomment when you *really understand* Pundit!
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  def user_not_authorized
    flash[:alert] = "You are not authorized to perform this action."
    redirect_to(root_path)
  end

  # app/controllers/application_controller.rb
  def after_sign_in_path_for(resource)
    case resource.role
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

  helper_method :current_donor, :current_charity

  private

  protect_from_forgery with: :exception

  def skip_pundit?
    devise_controller? || params[:controller] =~ /(^(rails_)?admin)|(^pages$)/
  end

  def set_locale
    return if devise_controller?

    session[:locale] = params[:switch_locale] if params[:switch_locale].present? && valid_locale?(params[:locale])

    I18n.locale = resolved_locale
  end

  def resolved_locale
    if session[:locale].present? && valid_locale?(session[:locale])
      session[:locale]
    elsif current_user&.locale.present?
      current_user.locale
    else
      I18n.default_locale
    end
  end

  def valid_locale?(loc)
    I18n.available_locales.map(&:to_s).include?(loc.to_s)
  end

  def default_url_options
    { locale: I18n.locale }
  end

  def current_donor
    @current_donor ||= current_user&.donor
  end

  def current_charity
    @current_charity ||= current_user&.charity
  end
end
