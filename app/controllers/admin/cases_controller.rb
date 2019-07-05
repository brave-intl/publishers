module Admin
  class CasesController < AdminController
    include ActiveRecord::Sanitization::ClassMethods

    def index
      @cases = Case.all
      @cases = Case.order(sanitize_sql_for_order("#{sort_column} #{sort_direction} NULLS LAST"))

      unless has_filter?
        if Case.where(assignee: current_user, status: Case::ASSIGNED).size.positive?
          redirect_to admin_cases_path(status: Case::ASSIGNED, assigned: current_user.id) and return
        else
          redirect_to admin_cases_path(status: Case::OPEN)
        end
      end

      if params[:status].present? && Case::ALL_STATUSES.include?(params[:status])
        # Effectively sanitizes the users input
        status = Case::ALL_STATUSES.detect { |x| x == params[:status] }
        @cases = @cases.where(status: status)
      end

      @cases = search if params[:q].present?
      @cases = @cases.order(open_at: :asc).paginate(page: params[:page])

      @open_cases = Case.where(status: Case::OPEN)
      @assigned_cases = Case.where(assignee: current_user, status: Case::ASSIGNED)
    end

    def search
      search_case = Case
      query = params[:q].strip.downcase
      return search_case if query.blank?

      # Search by case
      if query.include?("#") || query.length == 5
        case_id = query.split('#').second
        case_id = query if case_id.blank?
        search_case = Case.where("id::text LIKE ?", "%#{ case_id }")
      elsif query.include?(":")
        # Search for each type on the db model, like assignee = ""
        query.split(' ').each do |term|
          type, value = term.split(':')
          case type
          when 'assigned'
            @assigned = Publisher.where('email like ? AND role = ?', "%#{value}%", 'admin').first
            search_case = search_case.joins(:assignee).where('publishers.email LIKE ?', "%#{value}%")
          when 'status'
            search_case = search_case.where('status LIKE ?', "%#{value}%")
          end
        end
      else
        search_case = Case.joins(:publisher).where('publishers.name LIKE ?', "%#{query}%")
      end

      search_case
    end

    def overview
      @open_cases = Case.where(status: Case::OPEN)
      @assigned_cases = Case.where(assignee: current_user, status: Case::ASSIGNED)

      @case_status = Case.all.group(:status).count
      @assigned = Case.all.joins(:assignee).group('publishers.name', :status).count

      @assigned = @assigned.sort_by { |x, y| y }.reverse

      @assigned = @assigned.to_a
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
      assignee = Publisher.where("email LIKE ? AND role='admin'", "#{params[:email].strip}%").first if params[:email].present?

      @case.update(assignee: assignee)
      redirect_to admin_case_path(@case)
    end

    def update
      @case = Case.find(params[:id])
      @case.update(status: params[:status])

      redirect_to admin_case_path(@case)
    end

    def has_filter?
      params[:status].present? || params[:assigned].present? || params[:q].present? || sort_column != :id
    end

    def sortable_columns
      [:open_at, :assignee_id]
    end
  end
end
