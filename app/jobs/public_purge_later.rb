class PublicPurgeJob < ActiveStorage::BaseJob
  retry_on StandardError

  def perform(self, name)
    self.public_send("#{name}_detach")
  end
end
