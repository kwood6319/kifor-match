class RequestsController < ApplicationController
  before_action :set_request, only: %i[show edit update]

  def index
    # Start with your policy scope and include charity to avoid N+1 queries
    @requests = policy_scope(Request).includes(:charity).where.not(status: "inactive")

    # Setup dynamic variables for your dropdown menus
    @categories = Request.pluck(:category).uniq.sort

    # 1. Text Search (Title or Charity Name)
    if params[:query].present?
      # ILIKE is PostgreSQL's case-insensitive search
      sql_query = "requests.title ILIKE :query OR charities.org_name ILIKE :query"
      # We must join the charities table so SQL knows what 'charities.org_name' is
      @requests = @requests.joins(:charity).where(sql_query, query: "%#{params[:query]}%")
    end

    # 2. Category Filter
    @requests = @requests.where(category: params[:category]) if params[:category].present?

    # 3. Prefecture Filter
    if params[:prefecture].present?
      # We join charities again to filter by the associated charity's prefecture
      @requests = @requests.joins(:charity).where(charities: { prefecture: params[:prefecture] })
    end

    # 4. "No Offers Yet" Checkbox
    if params[:no_offers] == "1"
      # left_outer_joins grabs all requests, even if they have no offers.
      # where(offers: { id: nil }) filters it down to ONLY the ones with no matches.
      @requests = @requests.left_outer_joins(:offers).where(offers: { id: nil })
    end

    @requests = @requests.order(created_at: :desc)
  end

  def show
    authorize @request
    @offers = @request.offers
    @offer = Offer.new(request: @request, donor: current_user&.donor)
    @my_offer = (@offers.find_by(donor: current_user.donor) if current_user&.donor?)
    @editing_offer = @offers.find_by(id: params[:edit_offer])
  end

  def new
    @request = Request.new
    authorize @request
  end

  def create
    if current_user.charity.nil?
      redirect_to root_path
      return
    end
    @request = Request.new(request_params)
    @request.charity = current_user.charity
    @request.save ? redirect_to(request_path(@request)) : render(:new, status: :unprocessable_entity)
    authorize @request
  end

  def edit
    authorize @request
  end

  def update
    authorize @request

    old_needed = @request.quantity_needed

    if @request.update(request_params)
      difference = @request.quantity_needed - old_needed
      @request.increment!(:quantity_remaining, difference)
      redirect_to request_path
    else
      render :edit, status: :unprocessable_entity
    end

    authorize @request
  end

  # def activate
  # end

  # def deactivate
  #   authorize @request
  # end

  private

  def set_request
    @request = Request.find(params[:id])
  end

  def request_params
    params.require(:request).permit(:title, :category, :description, :quantity_needed, :quantity_remaining, :units,
                                    :condition, :urgency, :status, :estimated_arrival)
  end
end
