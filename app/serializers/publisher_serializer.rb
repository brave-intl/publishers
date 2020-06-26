class PublisherSerializer < ActiveModel::Serializer
  attributes :owner_identifier, :email, :name, :channel_identifiers, :default_currency

  def channel_identifiers
    object.channels.verified.collect do |channel|
      channel.details.channel_identifier
    end
  end

  def serializable_hash(adapter_options = nil, options = {}, adapter_instance = self.class.serialization_adapter_instance)
    hash = super
    hash.each { |key, value| hash.delete(key) if value.blank? }
    hash
  end
end
