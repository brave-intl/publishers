module Publishers
  class DevelopersController < ApplicationController
    def new
    end

    def show
      @keys = PaymentClient.key.all(publisher_id: current_publisher.id)
    end

    def create
      # binding.pry
      @key = Payment::Models::Key.new({"id"=>SecureRandom.uuid,
        "name"=>"key #{rand(1...1000)}",
        "merchant"=>SecureRandom.uuid,
        "secret_key"=>"kwAXLP1s5lCE5JhFj9pA9YtMh_nzBJAi",
        "created_at"=>"2020-04-03T20:08:50.700189Z",
        "expiry"=>nil})
      # @key = PaymentClient.key.create(publisher_id: current_publisher.id, name: params[:name])
      # binding.pry

    end
  end
end
