# typed: true

Rails.application.reloader.to_prepare do
  # rubocop:disable Lint/ConstantDefinitionInBlock
  PromoClient = Promo::Client.new
  # rubocop:enable Lint/ConstantDefinitionInBlock
end
