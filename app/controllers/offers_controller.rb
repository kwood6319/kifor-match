class OffersController < ApplicationController
  before_action :set_offer, only: %i[show destroy approve reject mark_received]
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
  end

  # TODO: new , form for creating new offer
  def new
    @offer = Offer.new
  end

  # TODO: create , presist new offer (default status = pending)
  def create
    @offer = Offer.new(offer_params)
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

  private

  # TODO: strong params, whitelist params
  def offer_params
    params.require(:offer).permit(:quantity_offered, :request_id, :donor_id)
  end

  # TODO: authorize only charity for specific actions

  def set_offer
    @offer = Offer.find(params[:id])
  end

  def authorize_charity
    unless current_user.role == "charity" &&
           @offer.request.charity_id == current_user.charity_id
      redirect_to request_offers_path(@offer.request)
    end
  end
end
