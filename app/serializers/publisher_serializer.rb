class PublisherSerializer < ActiveModel::Serializer
  attributes :id, :email, :name, :phone, :phone_normalized, :verified, :verification_token, :created_at, :updated_at, :last_sign_in_at
end
