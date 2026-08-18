class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:home]

  def home
  end

  def new_contact
    render :contact
  end

  def create_contact
    redirect_to root_path, status: :see_other, notice: t("contact.success")
  end
end
