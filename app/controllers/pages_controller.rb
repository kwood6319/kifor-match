class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[home new_contact]

  def home
  end

  def new_contact
    render :contact
  end
end
