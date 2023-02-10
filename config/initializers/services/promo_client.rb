# typed: true
Rails.application.reloader.to_prepare do
  PromoClient = Promo::Client.new
end