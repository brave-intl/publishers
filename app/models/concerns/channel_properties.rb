module ChannelProperties
  extend ActiveSupport::Concern
  include ActiveSupport::Inflector

  included do
    PROPERTIES = [] # rubocop:disable Style/MutableConstant

    def self.has_property(name, dependent: :purge_later)
      name = name.to_s

      ChannelProperties.const_set(name.upcase, name)
      PROPERTIES << name

      scope :"#{name}_channels", -> { joins(:"#{name}_channel_details") }
      scope :"other_verified_#{name}_channels", -> (id:) { send("#{name}_channels").where(verified: true).where.not(id: id) }

      scope :"visible_#{name.to_s}_channels", -> {
        send("#{name}_channels").where.not("#{name}_channel_details.#{name}_channel_id": nil)
      }

      belongs_to :"#{name}_channel_details", -> { where(channels: { details_type: "#{name.classify}ChannelDetails" }).includes(:channels) }, foreign_key: 'details_id'
    end
  end
end
