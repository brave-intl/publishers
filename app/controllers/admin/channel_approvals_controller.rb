module Admin
  class ChannelApprovalsController < AdminController
    def index
      @approvals = Channel.where(verification_status: 'awaiting_admin_approval').order(created_at: :desc)
    end
  end
end
