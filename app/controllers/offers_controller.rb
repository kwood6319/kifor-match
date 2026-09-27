class OffersController < ApplicationController
  before_action :set_offer, only: %i[show destroy approve reject mark_received mark_as_shipped]
  before_action :show_back_button, only: %i[show]

  def show
    @request = @offer.request
    @charity = @request.charity
    @donor = @offer.donor

    viewer_charity = current_user ? Charity.find_by(user_id: current_user.id) : nil
    owns_request = viewer_charity && @request.charity_id == viewer_charity.id
    submitted_status = @offer.status.to_s == "submitted"
    @can_approve = owns_request && submitted_status
    @can_reject = owns_request && submitted_status
    @can_mark_received = owns_request && %w[shipped].include?(@offer.status.to_s)
    authorize @offer
  end

  def create
    @request = Request.find(params[:request_id])
    @donor = current_user ? Donor.find_by(user_id: current_user.id) : nil
    @offer = Offer.new(offer_params)
    @offer.request ||= @request
    @offer.donor ||= @donor
    authorize @offer
    if @offer.save
      redirect_to request_path(@request)
    else
      render "requests/show", status: :unprocessable_entity
    end
  end

  def update
    @offer = Offer.find(params[:id])
    authorize @offer

    @offer.assign_attributes(offer_params.except(:photos, :remove_photo_ids))
    assign_updated_photos

    if @offer.save
      redirect_to request_path(@offer.request),
                  notice: "Offer updated."
    else
      @request = @offer.request
      @donor = @offer.donor
      @my_offer = @editing_offer = @offer
      render "requests/show", status: :unprocessable_entity
    end
  end

  # TODO: destroy , delete offer
  def destroy
    authorize @offer
    @offer.destroy
    redirect_to donors_dashboard_path, status: :see_other
  end

  # TODO: approve , approve offer (only Charities can approve offers)
  def approve
    authorize @offer
    @offer.status = "approved"
    @offer.save
    redirect_to request_path(@offer.request)
  end

  # TODO: reject , reject offer (only Charities can reject offers)
  def reject
    authorize @offer
    @offer.update(rejection_reason: params[:rejection_reason], status: :rejected)
    redirect_to request_path(@offer.request), status: :see_other
  end

  # TODO: update request.quantity_remaining when offer is received
  def update_received
    @request = Request.find(@offer.request_id)
    @request.quantity_remaining -= @offer.quantity_offered
    @request.save
  end

  # TODO: mark_received, change status to received (charity only)
  def mark_received
    authorize @offer
    @offer.status = "received"
    @offer.save
    update_received
    redirect_to request_path(@offer.request)
  end

  # TODO: mark_as_shipped, change status to shipped (donor only)
  def mark_as_shipped
    authorize @offer

    if @offer.update(
      offer_params.merge(status: "shipped")
    )
      redirect_to request_path(@offer.request),
                  notice: "Shipping info saved."
    else
      # Offers are edited on the request page, so send the errors back there
      redirect_to request_path(@offer.request), alert: @offer.errors.full_messages.to_sentence
    end
  end

  private

  def offer_params
    params.require(:offer).permit(:quantity_offered, :condition, :message, :can_ship_by, :ship_by_day,
                                  :ship_by_month_year, :estimated_arrival, :tracking_number, :rejection_reason,
                                  photos: [], remove_photo_ids: [])
  end

  # Assigning to has_many_attached replaces the whole set, so rebuild it from
  # the photos being kept plus any new uploads. Nothing is persisted until
  # save, so a failed validation (e.g. removing every photo) keeps the old set.
  def assign_updated_photos
    new_photos = Array(offer_params[:photos]).compact_blank
    remove_ids = Array(offer_params[:remove_photo_ids]).compact_blank.map(&:to_i)
    return if new_photos.empty? && remove_ids.empty?

    kept = @offer.photos.attachments.reject { |attachment| remove_ids.include?(attachment.id) }.map(&:blob)
    @offer.photos = kept + new_photos
  end

  def set_offer
    @offer = Offer.find(params[:id])
  end
end
