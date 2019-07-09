module Admin
  class CaseNotesController < AdminController
    def create
      note = CaseNote.create(case_notes_params.merge(created_by_id: current_publisher.id))

      redirect_to admin_case_path(note.case)
    end

    def update
      CaseNote.find(params[:id]).update(public: false)
    end

    private

    def case_notes_params
      params.require(:case_note).permit(:case_id, :note, :public, files: [])
    end
  end
end
