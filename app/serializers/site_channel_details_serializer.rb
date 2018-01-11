class SiteChannelDetailsSerializer < ActiveModel::Serializer
  attributes :id, :verification_method, :verification_token, :created_at, :updated_at

  has_one :channel
end
