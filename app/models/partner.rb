class Partner < Publisher
  default_scope { where(role: PARTNER) }
  validates :created_by, presence: true
  has_one :membership, dependent: :destroy, foreign_key: :user_id
  has_one :organization, through: :membership

  has_many :reports

  after_initialize :ensure_role

  # Ensure that the role is always Partner
  def ensure_role
    self.role = 'partner'
  end
end
