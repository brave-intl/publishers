module Views
  module User
    class RateCards
      attr_accessor :rate_cards

      def initialize(statement, groups)
        @channel_identifiers = {}

        @rate_cards = []
        build(statement, groups)
      end

      def as_json(*)
        {
          rateCardStatement: rate_cards
        }
      end

      def build(statement, groups)
        by_property = statement.group_by { |x| x[:publisher] }

        by_property.each do |property, statements|
          rate_card = {
            referral_code: referral_code_for_channel(property),
            details: []
          }

          statements.group_by { |s| s[:groupId] }.each do |group_id, entries|
            group = groups.detect { |g| group_id == g[:id] }
            total_bat = entries.map { |x| x[:amount].to_f }.reduce(:+)
            average_amount_paid = total_bat / entries.size

            rate_card[:details] << {
              group: group,
              confirmations: entries.size,
              average_paid_per_confirmation: average_amount_paid,
              total_bat: total_bat
            }
          end
          rate_card[:details] = rate_card[:details].sort_by { |x| x[:group][:name] }

          rate_cards << rate_card
        end
      end

      def referral_code_for_channel(identifier)
        channel ||= @channel_identifiers[identifier]
        if channel.blank?
          @channel_identifiers[identifier] = Channel.find_by_channel_identifier(identifier)&.promo_registration&.referral_code
          @channel_identifiers[identifier] ||= identifier
        end

        @channel_identifiers[identifier]
      end
    end
  end
end
