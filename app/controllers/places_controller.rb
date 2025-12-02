class PlacesController < ApplicationController

  def index
    @places = policy_scope(Place)
  end
end
