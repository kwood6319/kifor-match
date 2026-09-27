class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[new_contact]

  def new_contact
    render :contact
  end
end
