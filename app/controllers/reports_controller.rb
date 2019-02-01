class ReportsController < ApplicationController
  def index
    @reports = Report.with_attached_file.joins(:file_attachment).where(partner: current_publisher)
    @reports = { reports: @reports }.to_json(methods: :filename)

    respond_to do |format|
      format.html
      format.json  { render json: @reports }
    end
  end

  def create
    report = Report.new(partner: current_publisher.becomes(Partner), uploaded_by: current_publisher.id)
    report.save
    report.file.attach(params[:file])
    report.save
  end
end
