class OffersController < ApplicationController
  before_action :set_offer, only: %i[show destroy approve reject mark_received mark_as_shipped]

  # TODO: index , list all offers
  def index
    @donor = Donor.find_by(user_id: current_user.id)
    @charity = Charity.find_by(user_id: current_user.id)

    @viewer_role = if current_user.respond_to?(:role) && current_user.role == "admin"
                     :admin
                   elsif @donor
                     :donor
                   elsif @charity
                     :charity
                   end

    @offers = policy_scope(Offer).includes(:donor, request: :charity)
    @offers = @offers.where(request_id: params[:request_id]) if params[:request_id]
  end

  # TODO: show , show one offer details
  def show
    @request = @offer.request
    @charity = @request.charity
    @donor = @offer.donor

    viewer_charity = current_user ? Charity.find_by(user_id: current_user.id) : nil
    owns_request = viewer_charity && @request.charity_id == viewer_charity.id
    submitted_status = @offer.status.to_s == "submitted"
    @can_approve = owns_request && submitted_status
    @can_reject = owns_request && submitted_status
    @can_mark_received = owns_request && %w[approved shipped].include?(@offer.status.to_s)
    authorize @offer
  end

  # TODO: new , form for creating new offer
  def new
    @request = Request.find(params[:request_id])
    @donor = current_user ? Donor.find_by(user_id: current_user.id) : nil
    @offer = Offer.new(request: @request, donor: @donor)
    authorize @offer
  end

  # TODO: create , persist new offer (default status = submitted)
  def create
    @request = Request.find(params[:request_id])
    @donor = current_user ? Donor.find_by(user_id: current_user.id) : nil
    @offer = Offer.new(offer_params)
    @offer.request ||= @request
    @offer.donor ||= @donor
    authorize @offer
    if @offer.save
      redirect_to @offer
    else
      render :new
    end
  end

  # TODO: destroy , delete offer
  def destroy
    authorize @offer
    @offer.destroy
    redirect_to request_offers_path(@offer.request)
  end

  # TODO: approve , approve offer (only Charities can approve offers)
  def approve
    authorize @offer
    @offer.status = "approved"
    @offer.save
    redirect_to request_offers_path(@offer.request)
  end

  # TODO: reject , reject offer (only Charities can reject offers)
  def reject
    authorize @offer
    @offer.status = "rejected"
    @offer.save
    redirect_to request_offers_path(@offer.request)
  end

  # TODO: search , implement search scope on Offer model when ready
  def search
    @offers = policy_scope(Offer)
    authorize Offer
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
    redirect_to request_offers_path(@offer.request)
  end

  # TODO: mark_as_shipped, change status to shipped (donor only)
  def mark_as_shipped
    authorize @offer
    @offer.status = "shipped"
    @offer.save
    redirect_to request_offers_path(@offer.request)
  end

  private

  # TODO: strong params, whitelist params
  def offer_params
    params.require(:offer).permit(:quantity_offered, :condition, :message, :can_ship_by, :photo)
  end

  def set_offer
    @offer = Offer.find(params[:id])
  end
end

# Nice to have : Search functionality for offers, filter by category, condition, prefecture, region, etc.
