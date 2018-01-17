class ChannelSerializer < ActiveModel::Serializer
  attributes :id, :verified, :created_at, :updated_at

  belongs_to :details, polymorphic: true
end
