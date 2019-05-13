module Views
  module Admin
    class NavigationView
      include ActiveModel::Model

      attr_accessor :publisher

      def initialize(publisher)
        @publisher = publisher
      end

      def as_json(*)
        {
          publisher: {
            id: publisher.id,
            name: publisher.name,
            status: publisher.last_status_update.status,
          },
        }
      end
    end
  end
end
