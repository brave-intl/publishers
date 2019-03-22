class Partner < Publisher
  default_scope { where(role: PARTNER) }
  validates :created_by, presence: true
  has_one :membership, dependent: :destroy, foreign_key: :user_id
  has_one :organization, through: :membership

  has_many :invoices

  after_initialize :ensure_role

  # Ensure that the role is always Partner
  def ensure_role
    self.role = 'partner'
  end

  def balance
    wallet.contribution_balance.amount_bat + invoice_amount
  end

  def balance_in_currency
    wallet.contribution_balance.add_bat(invoice_amount)
    wallet.contribution_balance.amount_default_currency
  end

  def name
    self[:name] || self[:email]
  end

  private

  def invoice_amount
    invoices = Invoice.where(partner_id: id, paid: false)
    amounts = invoices.map { |i| i.finalized_amount || i.amount }

    amounts.map { |x| x.tr(",", "").to_i }.reduce(:+) || 0
  end
end
