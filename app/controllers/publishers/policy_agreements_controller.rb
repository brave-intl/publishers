class Publishers::PolicyAgreementsController < PublishersController
  def new
    @policy_agreement = PolicyAgreement.new
  end

  def create
    flash[:alert] = I18n.t("publishers.policy_agreements.create.must_accept_tos") unless create_params[:accepted_publisher_tos] == 'true'
    flash[:alert] = I18n.t("publishers.policy_agreements.create.must_accept_privacy_policy") unless create_params[:accepted_publisher_privacy_policy] == 'true'
    redirect_to home_publishers_path and return if flash[:alert].present?
    result = PolicyAgreement.create(
      user_id: current_publisher.id,
      accepted_publisher_tos: create_params[:accepted_publisher_tos] == 'true',
      accepted_publisher_privacy_policy: create_params[:accepted_publisher_privacy_policy] == 'true'
    )

    redirect_to home_publishers_path
  end

  def create_params
    params.require(:policy_agreement)
      .permit(:accepted_publisher_tos, :accepted_publisher_privacy_policy)
  end
end
