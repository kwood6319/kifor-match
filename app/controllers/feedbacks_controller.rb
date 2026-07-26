class FeedbacksController < ApplicationController
  # No :index action here, so ApplicationController's :only/:except => :index
  # callbacks raise "Unknown action" on every request (Rails validates those
  # targets exist on the controller). Replace with unconditional equivalents.
  skip_after_action :verify_policy_scoped
  skip_after_action :verify_authorized
  after_action :verify_authorized, unless: :skip_pundit?

  def new
    @request = Request.find(params[:request_id])
    @grouped_tags = FeedbackTags.grouped_for(@request.category)
    authorize @request, :show?
  end

  def create
    @request = Request.find(params[:request_id])
    authorize @request, :show?

    # DEFERRED: persist? email Francis? POST JSON? For now, just acknowledge.
    Rails.logger.info("Feedback submitted for request #{@request.id}: #{params[:feedback].inspect}")
    redirect_to request_path(@request), notice: "Thanks for your feedback!"
  end
end
