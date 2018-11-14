class Partner < Publisher
  default_scope { where(role: PARTNER) }
  after_initialize :ensure_role

  validate :not_a_partner

  # Ensure that the role is always Partner
  def ensure_role
    self.role = 'partner'
  end

  def not_a_partner
    publisher = Publisher.by_email_case_insensitive(email).first
    return if publisher.nil?

    if publisher.partner?
      return errors.add(:base, 'Email is already a partner')
    end
  end
end
