module Admin
  class CasesController < AdminController
    def index
      @cases = Case.all
      redirect_to admin_cases_path(status: Case::OPEN) if params[:status].nil? && params[:assigned].blank?
      # params[:status] ||= Case::OPEN

      if params[:status].present? && Case::ALL_STATUSES.include?(params[:status])
        # Effectively sanitizes the users input
        status = Case::ALL_STATUSES.detect { |x| x == params[:status] }
        @cases = @cases.where(status: status)
      end

      if params[:assigned].present?
        @assigned = Publisher.find(params[:assigned])
        @cases = Case.where(assignee: @assigned, status: Case::ASSIGNED)

        @answered = @cases.select do |c|
          note = c.case_notes.where(public: true).order(created_at: :asc).last

          note&.created_by&.admin?
        end

        @cases = @cases.where.not(id: @answered.pluck(:id))
      end

      @cases = @cases.paginate(page: params[:page])

      @open_cases = Case.where(status: Case::OPEN)
      @assigned_cases = Case.where(assignee: current_user, status: Case::ASSIGNED)
    end

    def show
      @case = Case.find(params[:id])
      @notes = @case.case_notes.order(created_at: :desc)

      last_note = @notes.where(public: true).first
      @answered = last_note&.created_by&.admin?
    end

    def assign
      @case = Case.find(params[:case_id])
      assignee = current_user

      assignee = Publisher.where("email LIKE ?", "#{params[:email].strip}%").first if params[:email].present?

      @case.update(assignee: assignee)
      redirect_to admin_case_path(@case)
    end

    def update
      @case = Case.find(params[:id])
      @case.update(status: params[:status])

      redirect_to admin_case_path(@case)
    end
  end
end
