I18n.load_path += Dir["#{Rails.root.to_s}/config/locales/**/*.yml"]
I18n.default_locale = :en
I18n.available_locales = [:en, :ja]
