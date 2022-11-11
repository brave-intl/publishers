# typed: true

class PublisherStatusUpdater < BaseService
  class InvalidNote < StandardError; end
  class InvalidAdmin < StandardError; end
  class CannotSuspendWhitelisted < StandardError; end

  def perform(user:, admin:, status:, note:)
    # We should not automatically move publishers out of this status.
    if user.only_user_funds?
      return user.last_status_update
    end

    raise InvalidNote if note.blank?
    raise InvalidAdmin if admin.blank?

    if user.last_whitelist_update&.enabled && [PublisherStatusUpdate::NO_GRANTS, PublisherStatusUpdate::SUSPENDED].include?(status)
      raise CannotSuspendWhitelisted
    end

    status_update = PublisherStatusUpdate.create!(publisher: user, status: status)
    PublisherNote.create!(note: note, publisher: user, created_by: admin)

    # Email users who were put on hold via the API
    PublisherMailer.email_user_on_hold(@publisher).deliver_later if status == PublisherStatusUpdate::HOLD

    return status_update
  end
end
