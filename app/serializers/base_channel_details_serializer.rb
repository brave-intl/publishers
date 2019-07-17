class BaseChannelDetailsSerializer < ActiveModel::Serializer
  attributes :id, :show_verification_status, :method, :visible, :name, :email, :preferred_currency
  def id
    object.channel_identifier
  end

  def method
    object.verification_method
  end

  # roll up the channel and select owner details without using the AMS includes
  def show_verification_status
    visible
  end

  def visible
    object.channel.publisher.visible
  end

  def name
    object.channel.publisher.name
  end

  def email
    object.channel.publisher.email
  end

  def preferred_currency
    object.channel.publisher.uphold_connection.default_currency
  end
end
