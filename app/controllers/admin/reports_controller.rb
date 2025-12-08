module Admin
  class ReportsController < BaseController
    before_action :set_report, only: [:show, :update, :destroy]

    def index
      @reports = Report.includes(:user, :place).order(created_at: :desc)
      @reports = @reports.where(status: params[:status]) if params[:status].present?
    end

    def show
      @place = @report.place
    end

    def update
      if @report.update(report_params)
        redirect_to admin_reports_path, notice: "Report status updated."
      else
        render :show, status: :unprocessable_entity
      end
    end

    def destroy
      @report.destroy
      redirect_to admin_reports_path, notice: "Report deleted."
    end

    private

    def set_report
      @report = Report.find(params[:id])
    end

    def report_params
      params.require(:report).permit(:status)
    end
  end
end
