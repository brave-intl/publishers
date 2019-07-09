module Admin
  class CasesController < AdminController
    include ActiveRecord::Sanitization::ClassMethods

    before_action :redirect_on_no_filter, only: [:index]

    def index
      @cases = Case.all
      @cases = search if params[:q].present?

      if sort_column == :id
        @cases = @cases.order(open_at: :asc)
      else
        @cases = @cases.order(sanitize_sql_for_order("#{sort_column} #{sort_direction} NULLS LAST"))
      end

      @cases = @cases.paginate(page: params[:page])

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
        search_case = Case.where("case_number = ?", case_id)
      elsif query.include?(":")
        # Search for each type on the db model, like assignee = ""
        query.split(' ').each do |term|
          type, value = term.split(':')
          case type
          when 'assigned'
            @assigned = Publisher.where('email like ? AND role = ?', "%#{value}%", 'admin').first
            search_case = search_case.joins(:assignee).where('publishers.email LIKE ?', "%#{value}%")
          when 'status'
            # Remove all non-alphanumeric values from the status field
            value = value.gsub(/[^0-9a-z]/i, '')
            search_case = search_case.where('status LIKE ?', "%#{value}%") if value.present?
          end
        end
      else
        search_query = "%#{query}%"
        search_case = Case.joins(:publisher).where('publishers.name LIKE ?', search_query).or(
          Case.joins(:publisher).where('publishers.email LIKE ?', search_query)
        )
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

      if @case.update(status: params[:status])
        note = PublisherNote.create(
          publisher: @case.publisher,
          created_by: current_user,
          note: "The case was marked as 'Accepted' which triggered this state change to Active."
        )
        @case.publisher.status_updates.create(status: PublisherStatusUpdate::ACTIVE, publisher_note: note)
      end

      redirect_to admin_case_path(@case)
    end

    def has_filter?
      !params[:status].nil? || params[:assigned].present? || params[:q].present? || sort_column != :id
    end

    def sortable_columns
      [:open_at, :assignee_id, :status]
    end

    def redirect_on_no_filter
      return if  has_filter?

      if Case.where(assignee: current_user, status: Case::ASSIGNED).size.positive?
        redirect_to admin_cases_path(q: "status:#{Case::ASSIGNED} assigned:#{current_user.email.sub("@brave.com", '')}") and return
      else
        redirect_to admin_cases_path(status: Case::OPEN)
      end
    end
  end
end
