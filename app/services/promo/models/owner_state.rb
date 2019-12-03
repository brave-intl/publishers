require 'addressable/template'
require 'json'

module Promo
  module Models
    class OwnerState < Client
      # For more information about how these URI templates are structured read the explaination in the RFC
      # https://www.rfc-editor.org/rfc/rfc6570.txt
      PATH = Addressable::Template.new("api/2/promo/owners/{id}/states{/state}")

      class State
        SUSPEND = "suspend".freeze
        NO_UGP = "no_ugp".freeze
      end

      def initialize(connection, params = {})
        super(connection, params)
      end

      # Finds the current state of the owner on the promo server
      #
      # @param [String] id The publisher id to find on the promo server.
      #
      # @return [array] of owner states
      def find(id:)
        response = get(PATH.expand(id: id))

        JSON.parse(response.body)
      end

      # Creates a new state for the specified owner
      #
      # @param [String] id The publisher id
      # @state [Promo::Models::OwnerState::State] state The state to put the owner into.
      #
      # @return [true] if create was a success
      def create(id:, state:)
        response = put(PATH.expand(id: id, state: state))

        # response.body returns an array of owner states
        # ["no_ugp", "suspend"]
        JSON.parse(response.body).include? state
      end

      # Removes the state for the specified owner
      #
      # @param [String] id The publisher id
      # @param [Promo::Models::OwnerState::State] state The state to remove from the owner.
      #
      # @return [true] if destroy was a success
      def destroy(id:, state:)
        response = delete(PATH.expand(id: id, state: state))

        # response.body returns an array of owner states
        JSON.parse(response.body).exclude? state
      end
    end
  end
end
