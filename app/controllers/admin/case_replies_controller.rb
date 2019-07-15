module Admin
  class CaseRepliesController < AdminController
    def index
      @open_cases = Case.where(status: Case::OPEN)
      @assigned_cases = Case.where(assignee: current_user, status: Case::IN_PROGRESS)

      @replies = CaseReply.all
    end

    def create
      CaseReply.create(reply_params)
      redirect_to admin_case_replies_path, flash: { notice: "Your saved reply was created successfully."}
    end

    def edit
      @reply = CaseReply.find(params[:id])
      @open_cases = Case.where(status: Case::OPEN)
      @assigned_cases = Case.where(assignee: current_user, status: Case::IN_PROGRESS)
    end

    def update
      CaseReply.update(reply_params)
      redirect_to admin_case_replies_path, flash: { notice: "Your saved reply was updated successfully."}
    end

    def destroy
      CaseReply.find(params[:id]).destroy
      redirect_to admin_case_replies_path, flash: { notice: "Deleted the reply"}
    end


    private

    def reply_params
      params.require(:case_reply).permit(:id, :title, :body)
    end
  end
end
