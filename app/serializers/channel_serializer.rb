class ChannelSerializer < ActiveModel::Serializer
  attributes :id, :verified, :show_verification_status, :created_at, :updated_at

  belongs_to :details, polymorphic: true

  def show_verification_status
    object.show_verification_status?
  end
end
