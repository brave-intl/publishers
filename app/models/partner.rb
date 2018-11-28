class Partner < Publisher
  default_scope { where(role: PARTNER) }
  validates :created_by, presence: true

  after_initialize :ensure_role

  # Ensure that the role is always Partner
  def ensure_role
    self.role = 'partner'
  end
end
