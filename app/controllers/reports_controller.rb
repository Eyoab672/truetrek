class ReportsController < ApplicationController
  before_action :set_reportable

  def new
    @report = @reportable.reports.new
    authorize @report
  end

  def create
    @report = @reportable.reports.new(report_params)
    @report.user = current_user
    authorize @report

    if @report.save
      respond_to do |format|
        format.html { redirect_to redirect_path, notice: "Thank you for your report. Our team will review it shortly." }
        format.turbo_stream { flash.now[:notice] = "Thank you for your report. Our team will review it shortly." }
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_reportable
    if params[:place_id]
      @reportable = Place.find(params[:place_id])
    elsif params[:comment_id]
      @reportable = Comment.find(params[:comment_id])
    else
      raise ActiveRecord::RecordNotFound, "No reportable found"
    end
  end

  def redirect_path
    case @reportable
    when Place
      city_place_path(@reportable.city, @reportable)
    when Comment
      city_place_path(@reportable.place.city, @reportable.place)
    end
  end

  def report_params
    params.require(:report).permit(:reason)
  end
end
