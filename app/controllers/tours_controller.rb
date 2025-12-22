class ToursController < ApplicationController
  before_action :authenticate_user!
  skip_after_action :verify_authorized

  def complete
    current_user.update(tour_completed: true)
    head :ok
  end
end
