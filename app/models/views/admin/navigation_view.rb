# typed: false

module Views
  module Admin
    class NavigationView
      include ActiveModel::Model
      include ActionView::Helpers

      attr_accessor :publisher

      def initialize(publisher)
        @publisher = publisher
      end

      def avatar
        url = nil

        @publisher.channels.each do |channel|
          url = channel.details.thumbnail_url if channel.details.respond_to?(:thumbnail_url)
          break if url.present?
        end

        url
      end

      def as_json(*)
        name = publisher.name.present? ? publisher.name : publisher.email || publisher.pending_email
        {
          publisher: {
            id: publisher.id,
            name: name,
            status: publisher.last_status_update&.status,
            avatar: avatar
          }
        }
      end
    end
  end
end
