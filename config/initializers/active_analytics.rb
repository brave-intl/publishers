Rails.application.reloader.to_prepare do
  ActiveAnalytics::ApplicationController.class_eval do
    include RequirePubAdmin

    def current_user
      current_publisher
    end

    def current_ability
      @current_ability ||= Ability.new(current_user, request.remote_ip)
    end
  end
end
