class ReportsController < ApplicationController
  def index
  end

  def create
    report = Report.new(partner: current_publisher.becomes(Partner), uploaded_by: current_publisher)
    report.save
    report.file.attach(params[:file])
    report.save
  end
end
