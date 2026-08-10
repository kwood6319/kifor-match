class ApplicationController < ActionController::Base
  before_action :set_locale
  before_action :authenticate_user!
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
    I18n.locale = params[:locale].presence || I18n.default_locale
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
