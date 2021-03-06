class ListingsController < ApplicationController
  before_action :set_listing, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!

  # GET /listings
  def index
    @listings = Listing.all
    @is_employer = User.find(current_user.id).is_employer?
  end

  # GET /listings/1
  def show
    @listings = Listing.find(params[:id])
    @is_employer = User.find(current_user.id).is_employer?
  end

  # GET /listings/new
  def new
    @listing = Listing.new
  end

  # GET /listings/1/edit
  def edit
  end

  # POST /listings
  def create
    @listing = Listing.new(listing_params)
    @listing.employer_profile_id = current_user.id
    if @listing.save
      params[:listing][:skill].each do |skill|
        if skill[:skill_id].present?
          @listing.skills << Skill.find(skill[:skill_id].to_i)
        end
      end
      redirect_to @listing, notice: 'Listing was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /listings/1
  def update
    if @listing.update(listing_params)
      redirect_to @listing, notice: 'Listing was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /listings/1
  def destroy
    @listing.destroy
    redirect_to listings_url, notice: 'Listing was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_listing
      @listing = Listing.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def listing_params
      params[:listing].permit(:title, :body, :location, :accepted, :offered, :published,
        :min_salary, :max_salary, :hours)
    end
end
