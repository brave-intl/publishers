class PublisherSerializer < ActiveModel::Serializer
  attributes :id, :email, :name, :phone, :phone_normalized, :verified, :verification_method, :verification_token, :show_verification_status, :created_at, :updated_at, :last_sign_in_at
end
