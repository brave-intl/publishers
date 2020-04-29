class BaseChannelDetailsSerializer < ActiveModel::Serializer
  attributes :id, :method, :name, :email, :preferred_currency
  def id
    object.channel_identifier
  end

  def method
    object.verification_method
  end

  def name
    object.channel.publisher.name
  end

  def email
    object.channel.publisher.email
  end

  def preferred_currency
    object.channel.publisher&.uphold_connection&.default_currency
  end
end
