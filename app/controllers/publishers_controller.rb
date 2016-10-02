class PublishersController < ApplicationController
  def new
    @publisher = Publisher.new
  end

  def create
    @publisher = Publisher.new(publisher_params)
    if @publisher.save
      sign_in(:publisher, @publisher)
      redirect_to current_publishers_path
    else
      render :new
    end
  end

  def update
    # person = current_account.people.find(params[:id])
    # person.update!(person_params)
    # redirect_to person
  end

  def current

  end

  private

  def publisher_params
    params.require(:publisher)
          .permit(:bitcoin_address, :email, :etld, :name, :phone)
  end
end
