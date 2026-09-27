class ApplicationController < ActionController::Base
  before_action :set_locale
  before_action :redirect_to_resolved_locale
  before_action :authenticate_user!
  skip_before_action :authenticate_user!, if: :devise_controller?
  before_action :require_profile, unless: :devise_controller?
  before_action :require_approval, unless: :devise_controller?
  before_action :configure_permitted_parameters, if: :devise_controller?
  include Pundit::Authorization

  # Pundit: allow-list
  #
  # Deliberately not using `only: :index` / `except: :index` here: Rails
  # validates those action names against each subclass's defined actions
  # (raise_on_missing_callback_actions, on in test/production by default),
  # so any controller without a literal :index action - Devise's included
  # controllers, our own dashboard/feedback/notification controllers - would
  # raise "Unknown action" on every request. Lambdas check action_name at
  # runtime instead, sidestepping that validation entirely.
  after_action :verify_authorized, unless: -> { skip_pundit? || action_name == "index" }
  after_action :verify_policy_scoped, unless: -> { skip_pundit? || action_name != "index" }

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
    # Devise pages follow the URL only: touching current_user here would run
    # Warden before the CSRF check on sign-in and invalidate the token.
    return I18n.locale = (valid_locale?(params[:locale]) ? params[:locale] : I18n.default_locale) if devise_controller?

    session[:locale] = params[:switch_locale] if params[:switch_locale].present? && valid_locale?(params[:locale])

    I18n.locale = resolved_locale
  end

  # Keep the /en or /ja in the URL in step with the language the page is
  # actually shown in (saved preference or navbar switch).
  def redirect_to_resolved_locale
    return if devise_controller? || !request.get? || !request.format.html?
    return if params[:locale].blank? || params[:locale] == I18n.locale.to_s

    redirect_to request.fullpath.sub(%r{\A/#{params[:locale]}(?=/|\?|\z)}, "/#{I18n.locale}")
  end

  def resolved_locale
    if session[:locale].present? && valid_locale?(session[:locale])
      session[:locale]
    elsif current_user&.locale.present?
      current_user.locale
    elsif valid_locale?(params[:locale])
      # Guests have no saved preference, so follow the URL
      params[:locale]
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

  # New users keep the language they signed up in; otherwise the "en" column
  # default would switch them to English straight after sign-up.
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:locale])
  end

  # Sign-up only creates the User, so donors and charities finish onboarding
  # before they can use the rest of the app.
  def require_profile
    return if !user_signed_in? || current_user.admin? || current_profile

    redirect_to onboarding_path
  end

  # Only charities need admin approval; until then they can still reach
  # settings and the contact page.
  def require_approval
    return if !user_signed_in? || current_charity.nil? || current_charity.approved?
    return if controller_name.in?(%w[settings pages])

    redirect_to pending_approval_path
  end

  def current_profile
    current_donor || current_charity
  end

  def current_donor
    @current_donor ||= current_user&.donor
  end

  def current_charity
    @current_charity ||= current_user&.charity
  end

  def show_back_button
    @show_back_button = true
  end
end
