# typed: strict
# frozen_string_literal: true

class GeminiConnectionForChannel < ApplicationRecord
  belongs_to :gemini_connection
  belongs_to :channel

  validates :channel_identifier, uniqueness: {scope: [:gemini_connection_id, :channel_identifier]}
end
