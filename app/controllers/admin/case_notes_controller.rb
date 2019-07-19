module Admin
  class CaseNotesController < AdminController
    def create
      note = CaseNote.create(case_notes_params.merge(created_by_id: current_publisher.id))

      redirect_to admin_case_path(note.case)
    end

    def update
      note = CaseNote.find(params[:id])
      note.update(public: false)
      redirect_to admin_case_path(note.case)
    end

    private

    def case_notes_params
      params.require(:case_note).permit(:case_id, :note, :public, files: [])
    end
  end
end
