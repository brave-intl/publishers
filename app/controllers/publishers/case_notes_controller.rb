module Publishers
  class CaseNotesController < ApplicationController
    before_action :authenticate_publisher!
    before_action :authorize

    def create
      @case = Case.find_by(publisher: current_publisher)

      if @case.open? || @case.in_progress?
        note = CaseNote.create(case_notes_params.merge(case_id: @case.id, created_by_id: current_publisher.id))
      end

      if note.valid?
        redirect_to case_path
      else
        redirect_to case_path, alert: note.errors.full_messages.join(", ")
      end
    end

    private

    def case_notes_params
      params.require(:case_note).permit(:note, files: [])
    end

    def authorize
      raise unless current_publisher.no_grants?
    end
  end
end
