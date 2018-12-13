class PublicPurgeJob < ApplicationJob
  retry_on StandardError

  def perform(object:, name:)
    object.public_send("#{name}_detach")
  end
end
