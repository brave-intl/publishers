class Oauth2RefreshJob < ApplicationJob
  extend T::Sig
  queue_as :default

  # Serialization of the model is awkward here. Will need to look into it
  sig { params(connection_id: String, model: Class).returns(Oauth2RefresherService::TYPES) }
  def perform(connection_id, model)
    connection = model.find_by_id!(connection_id)
    Oauth2RefresherService.build.call(connection)
  end
end
