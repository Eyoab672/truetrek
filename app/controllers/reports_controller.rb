class ReportsController < ApplicationController
  before_action :set_place

  def new
    @report = @place.reports.new
    authorize @report
  end

  def create
    @report = @place.reports.new(report_params)
    @report.user = current_user
    authorize @report

    if @report.save
      respond_to do |format|
        format.html { redirect_to city_place_path(@place.city, @place), notice: "Thank you for your report. Our team will review it shortly." }
        format.turbo_stream { flash.now[:notice] = "Thank you for your report. Our team will review it shortly." }
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_place
    @place = Place.find(params[:place_id])
  end

  def report_params
    params.require(:report).permit(:reason)
  end
end
