class PublisherSerializer < ActiveModel::Serializer
  attributes :owner_identifier, :email, :name, :phone, :phone_normalized, :channel_identifiers

  def channel_identifiers
    object.channels.verified.collect do |channel|
      channel.details.channel_identifier
    end
  end
end