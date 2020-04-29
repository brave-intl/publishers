# Takes a SiteChannelDetaisl

class TokenSerializer < ActiveModel::Serializer
  attributes :owner_identifier, :brave_publisher_id, :verification_token, :verification_id

  def owner_identifier
    object.channel.publisher.owner_identifier
  end

  def verification_id
    object.channel.id
  end
end