class OffersController < ApplicationController
  before_action :set_offer, only: %i[show destroy approve reject mark_received mark_as_shipped]
  before_action :authorize_charity, only: %i[approve reject mark_received]

  # TODO: index , list all offers
  def index
    @offers = Offer.none
    @viewer_role = nil
    @donor = nil
    @charity = nil

    return unless current_user

    if current_user.respond_to?(:role) && current_user.role == "admin"
      @viewer_role = :admin
      @offers = Offer.all
      raise ArgumentError, "No offers available yet" if @offers.blank?

      return
    end

    @donor = Donor.find_by(user_id: current_user.id)
    if @donor
      @viewer_role = :donor
      @offers = Offer.includes(request: :charity).where(donor_id: @donor.id)
      return
    end

    @charity = Charity.find_by(user_id: current_user.id)
    return unless @charity

    @viewer_role = :charity
    @offers = Offer.includes(:donor, request: :charity)
                   .where(requests: { charity_id: @charity.id })
                   .references(:requests)
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
  end

  # TODO: new , form for creating new offer
  def new
    @request = Request.find(params[:request_id])
    @donor = current_user ? Donor.find_by(user_id: current_user.id) : nil
    @offer = Offer.new(request: @request, donor: @donor)
  end

  # TODO: create , presist new offer (default status = submitted)
  def create
    @request = Request.find(params[:request_id])
    @donor = current_user ? Donor.find_by(user_id: current_user.id) : nil
    @offer = Offer.new(offer_params)
    @offer.request ||= @request
    @offer.donor ||= @donor
    if @offer.save
      redirect_to @offer
    else
      render :new
    end
  end

  # TODO: destroy , delete offer
  def destroy
    @offer = Offer.find(params[:id])
    @offer.destroy
    redirect_to request_offers_path(@offer.request)
  end

  # TODO: approve , approve offer (only Charities can approve offers)
  def approve
    @offer.status = "approved"
    @offer.save
    redirect_to request_offers_path(@offer.request)
  end

  # TODO: reject , reject offer (only Charities can reject offers)
  def reject
    @offer.status = "rejected"
    @offer.save
    redirect_to request_offers_path(@offer.request)
  end

  # TODO: search , search for offers
  def search
    @offers = Offer.search(params[:search])
  end

  # TODO: update request.quantity_remaining when offer is received
  def update_received
    @request = Request.find(@offer.request_id)
    @request.quantity_remaining -= @offer.quantity_offered
    @request.save
  end

  # TODO: mark_received, change status to received (charity only)
  def mark_received
    @offer.status = "received"
    @offer.save
    update_received
    redirect_to request_offers_path(@offer.request)
  end

  # TODO: mark_as_shipped, change status to shipped (donor only)
  def mark_as_shipped
    @offer.status = "shipped"
    @offer.save
    redirect_to request_offers_path(@offer.request)
  end

  private

  # TODO: strong params, whitelist params
  def offer_params
    params.require(:offer).permit(:quantity_offered, :condition, :message, :can_ship_by, :request_id, :donor_id)
  end

  # TODO: authorize only charity for specific actions

  def set_offer
    @offer = Offer.find(params[:id])
  end

  def authorize_charity
    unless current_user.role == "charity" &&
        @offer.request.charity.user_id == current_user.id
      redirect_to request_offers_path(@offer.request)
    end
  end
end

# Nice to have : Search funcionality for offers, filter by category, condition, city, region, etc.
