module Publishers
  class CasesController < ApplicationController
    before_action :authenticate_publisher!
    before_action :authorize

    def new
      @case = Case.find_or_create_by!(publisher: current_publisher)
      redirect_to case_path unless @case.new?
    end

    def show
      @case = Case.find_by(publisher: current_publisher)
      @notes = CaseNote.where(case: @case)

      redirect_to new_case_path if @case.blank? || @case.new?
    end

    def update
      # Publisher only allowed one case
      @case = Case.find_by(publisher: current_publisher)
      redirect_to new_case_path and return unless @case.new?

      if params[:status].present?
        @case.status = Case::OPEN
        raise unless case_params[:solicit_question]&.strip.present? && case_params[:accident_question]&.strip.present?
      end

      @case.update(case_params)

      respond_to do |format|
        format.html { redirect_to new_case_path }
        format.js   {}
        format.json { render :new, status: :updated, location: @case }
      end
    end

    def delete_file
      attachment = ActiveStorage::Attachment.find(params[:id])
      attachment.purge_later
      redirect_to new_case_path
    end

    private

    def case_params
      params.require(:case).permit(:solicit_question, :accident_question, files: [])
    end

    def authorize
      raise unless current_publisher.no_grants?
    end
  end
end
