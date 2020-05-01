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
      @assigned_cases = Case.where(assignee: current_user, status: Case::IN_PROGRESS)
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
        search_case = parse_search(search_case, query.split(' '))
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
      @assigned_cases = Case.where(assignee: current_user, status: Case::IN_PROGRESS)

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

      @replies = CaseReply.all
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

      case_updated = @case.update(status: params[:status])
      if case_updated && params[:status] == Case::RESOLVED
        note = PublisherNote.create(
          publisher: @case.publisher,
          created_by: current_user,
          note: "The case was marked as 'Resolved' which triggered this state change to Active."
        )
        @case.publisher.status_updates.create(status: PublisherStatusUpdate::ACTIVE, publisher_note: note)
      end

      return redirect_to [:admin, @case], flash: { notice: "Case has been moved back to in progress"} if params[:status] == Case::IN_PROGRESS

      next_case = Case.where(assignee: current_user, status: Case::IN_PROGRESS).take
      if next_case
        redirect_to [:admin, next_case], flash: { notice: "Previous case #{@case.number} has been marked #{params[:status]}"}
      else
        redirect_to admin_cases_path
      end
    end

    private

    def parse_search(search_case, queries)
      statuses = queries.select { |x| x.include?("status") }.map { |x| x.split(':').last&.gsub(/[^0-9a-z_]/i, '') }
      assigned = queries.select { |x| x.include?("assigned") }.map { |x| x.split(':').last&.gsub(/[^0-9a-z_]/i, '') }

      search_case = search_case.where(status: statuses) if statuses.present?

      first_assigned = assigned[0]
      if first_assigned.present?
        value = first_assigned
        search_case = search_case.joins(:assignee).where('publishers.email LIKE ?', "#{value}%")

        assigned[1..-1].each do |value|
          search_case = search_case.or(Case.joins(:assignee).where('publishers.email LIKE ?', "#{value}%"))
        end
      end

      search_case
    end

    def has_filter?
      !params[:status].nil? || params[:assigned].present? || params[:q].present? || sort_column != :id
    end

    def sortable_columns
      [:open_at, :assignee_id, :status]
    end

    def redirect_on_no_filter
      return if  has_filter?

      if Case.where(assignee: current_user, status: Case::IN_PROGRESS).size.positive?
        redirect_to admin_cases_path(q: "status:#{Case::IN_PROGRESS} assigned:#{current_user.email.sub("@brave.com", '')}") and return
      else
        redirect_to admin_cases_path(q: "status:#{Case::OPEN}")
      end
    end
  end
end
