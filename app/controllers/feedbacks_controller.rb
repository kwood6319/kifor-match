class FeedbacksController < ApplicationController
  before_action :show_back_button, only: %i[new]

  def new
    @request = Request.find(params[:request_id])
    @offer = @request.offers.find(params[:offer_id])
    @grouped_tags = FeedbackTags.grouped_for(@request.category)
    authorize @offer, :complete?
  end

  def create
    @request = Request.find(params[:request_id])
    @offer = @request.offers.find(params[:offer_id])
    authorize @offer, :complete?

    # DEFERRED: persist? email Francis? POST JSON? For now, just acknowledge.
    # TO DO (raise with the group): feedback is not saved anywhere yet.
    Rails.logger.info("Feedback submitted for request #{@request.id}: #{params[:feedback].inspect}")
    @offer.update!(status: "completed")
    redirect_to request_path(@request), notice: t("feedback.thanks")
  end
end
