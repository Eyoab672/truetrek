class CitiesController < ApplicationController
  def index
    @cities = policy_scope(City).order(:name).limit(15)
  end
end
