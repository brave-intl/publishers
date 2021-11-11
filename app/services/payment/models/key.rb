# typed: ignore
require "addressable/template"
require "json"

module Payment
  module Models
    class Key < Client
      include Initializable

      attr_accessor :id, :name, :merchant, :secret_key, :created_at, :expiry

      # For more information about how these URI templates are structured read the explaination in the RFC
      # https://www.rfc-editor.org/rfc/rfc6570.txt
      PATH = Addressable::Template.new("v1/merchants/{publisher_id}/keys{/id}")

      def create(publisher_id:, name:)
        response = post(PATH.expand(publisher_id: publisher_id), {name: name})

        self.class.new(JSON.parse(response.body))
      end

      def all(publisher_id:)
        response = get(PATH.expand(publisher_id: publisher_id))

        keys = JSON.parse(response.body)&.map { |x| x.transform_keys(&:underscore) }
        keys ||= []

        keys.map do |k|
          self.class.new(k)
        end
      end

      def destroy(publisher_id:, id:, seconds:)
        options = {delaySeconds: seconds}

        response = delete(PATH.expand(publisher_id: publisher_id, id: id), options)

        self.class.new(JSON.parse(response.body))
      end
    end
  end
end
