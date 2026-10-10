class FeedbacksController < ApplicationController
  before_action :set_offer
  before_action :show_back_button, only: %i[new create edit update]

  def new
    @feedback = Feedback.new(offer: @offer)
    authorize @feedback
  end

  # Giving feedback is the charity's last step, so it also completes the offer
  def create
    @feedback = Feedback.new(feedback_params.merge(offer: @offer))
    authorize @feedback

    if save_and_complete_offer
      redirect_to request_path(@offer.request), notice: t("feedback.thanks")
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @feedback = @offer.feedback or raise ActiveRecord::RecordNotFound
    authorize @feedback
  end

  def update
    @feedback = @offer.feedback or raise ActiveRecord::RecordNotFound
    authorize @feedback

    if @feedback.update(feedback_params)
      redirect_to offer_path(@offer), notice: t("feedback.updated")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_offer
    @offer = Offer.includes(request: :charity).find(params[:offer_id])
    @request = @offer.request
    @grouped_tags = FeedbackTags.grouped_for(@request.category)
  end

  def save_and_complete_offer
    Feedback.transaction do
      next false unless @feedback.save

      # System status change, like Request#archive!: skip validation so older
      # offer data (photos, dates) can't block it. Callbacks still run, so the
      # donor gets the "completed" notification.
      @offer.status = "completed"
      @offer.save!(validate: false)
    end
  end

  def feedback_params
    params.require(:feedback).permit(:comment, :escalated, tags: [])
  end
end
