class PublishersController < ApplicationController
  def new
    @publisher = Publisher.new
  end

  def create
    @publisher = Publisher.new(publisher_params)
    if @publisher.save
      render text: 201
    else
      render :new
    end
  end

  def update
    # person = current_account.people.find(params[:id])
    # person.update!(person_params)
    # redirect_to person
  end

  private

  def publisher_params
    params.require(:publisher).permit(:etld, :name, :email, :bitcoin_address)
  end
end
