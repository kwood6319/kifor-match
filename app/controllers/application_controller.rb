class ApplicationController < ActionController::Base
  before_action :set_locale
  before_action :authenticate_user!
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

  private

  def skip_pundit?
    devise_controller? || params[:controller] =~ /(^(rails_)?admin)|(^pages$)/
  end

  def set_locale
    I18n.locale = params[:locale].presence || I18n.default_locale
  end

  def default_url_options
    { locale: I18n.locale }
  end
end
