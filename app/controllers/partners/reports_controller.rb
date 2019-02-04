module Partners
  class ReportsController < ApplicationController
    before_action :filter_users

    def index
      @reports = Report
        .with_attached_file
        .joins(:file_attachment)
        .where(partner: current_publisher)
        .order(created_at: :desc)

      @reports = { reports: @reports }.to_json

      respond_to do |format|
        format.html
        format.json  { render json: @reports }
      end
    end

    def create
      report = Report.new(
        partner: current_publisher.becomes(Partner),
        uploaded_by: current_publisher,
        amount_bat: params[:amount_bat]
      )
      report.save
      report.file.attach(params[:file])
      report.save
    end

    private

    #Internal: only allow users who are on the new UI whitelist to be allowed to access controller
    #
    # Returns nil
    def filter_users
      raise unless current_user&.in_new_ui_whitelist?
    end
  end
end
