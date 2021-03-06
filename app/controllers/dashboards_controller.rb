class DashboardsController < ApplicationController
  before_action :require_login
  # GET /dashboards
  def index
    # return all the listings if the user has a profile already
    if current_user.has_profile?
      @user = User.find(current_user.id)
      if @user.is_employer?
        @applications = []
        @matches = Hash.new
        # find all the matched hunters for each listing for an employer_profile
        # and return a hash of hunters for each listing
        @user.employer_profile.listings.each do |listing|
          # get all of the matches for a listing
          matchedHunters = find_listing_matches(listing.id)
          # store an array of the hunters
          @matches.store(listing, matchedHunters)
          # get all of the applications
          employments = Employment.where(:listing_id => listing.id, :offer => false)
          if !employments.nil?
            employments.each do |e|
              if @applications.find_all{|app| app['user_id'] == e.hunter_profile.user.id}.count == 0
                @applications.append(HunterProfile.find(e.hunter_profile_id))
              end
            end
          end
        end
      else
        @matches, @offers = [], []
        # otherwise find all of the matches for a hunter_profile from the join
        # table between listings and hunters
        employments = Employment.where(:hunter_profile_id => @user.hunter_profile.id)
        if !employments.nil?
          employments.each do |e|
            @offers.append(Listing.find(e.listing_id))
          end
        end
      end
      # return the matches or offers or application for each user
      @matches
      @offers
      @applications
    end
  end
end
