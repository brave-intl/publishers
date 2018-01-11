class PublisherSerializer < ActiveModel::Serializer
  attributes :owner_identifier, :email, :name, :phone, :phone_normalized, :last_sign_in_at, :created_at, :updated_at
  has_many :channels
end
