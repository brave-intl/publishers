module Publishers
  class CasesController < ApplicationController
    def new
      @case = Case.find_or_create_by!(publisher: current_publisher)
      redirect_to case_path if @case.open?
    end

    def show
      @case = Case.find_by(publisher: current_publisher)
      @notes = CaseNote.where(case: @case)
    end

    def update
      # Publisher only allowed one case so this is okay for now
      @case = Case.find_by(publisher: current_publisher)

      @case.update(case_params)

      respond_to do |format|
        format.html { redirect_to new_case_path, notice: 'User was successfully created.' }
        format.js   { }
        format.json { render :new, status: :updated, location: @case }
      end
    end

    def open
      @case = Case.find_by(publisher: current_publisher)
      @case.update(status: Case::OPEN) if @case.new?

      redirect_to case_path
    end

    def file_upload
    end

    def case_params
      params.require(:case).permit(:solicit_question, :accident_question)
    end
  end
end
