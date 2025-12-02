class CitiesController < ApplicationController

  def index
    @cities = policy_scope(City)
  end

end
