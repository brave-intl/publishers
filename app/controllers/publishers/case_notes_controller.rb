module Publishers
  class CaseNotesController < ApplicationController
    before_action :authenticate_publisher!
    before_action :authorize

    def create
      @case = Case.find_by(publisher: current_publisher)

      if @case.open?
        CaseNote.create( case_notes_params.merge(case_id: @case.id, created_by_id: current_publisher.id))
      end

      redirect_to case_path
    end

    private

    def case_notes_params
      params.require(:case_note).permit(:note)
    end

    def authorize
      raise unless current_publisher.no_grants?
    end
  end
end
