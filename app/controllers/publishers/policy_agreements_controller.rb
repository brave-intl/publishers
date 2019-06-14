class Publishers::PolicyAgreementsController < ApplicationController
  def new
  end

  def create
    flash[:alert] = "You must accept the Terms of Service to proceed" unless create_params[:accepted_publisher_tos] == 'true'
    flash[:alert] = "You must accept the Privacy Policy to proceed" unless create_params[:accepted_publisher_privacy_policy] == 'true'
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
