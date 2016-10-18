# frozen_string_literal: true
class PublisherLegalForm < ApplicationRecord
  AFTER_SIGN_TOKEN_VALID_DURATION = 1.week

  has_paper_trail
  attr_encrypted :s3_key, key: :encryption_key

  belongs_to :publisher

  delegate :brave_publisher_id, :email, :name, to: :publisher

  validates_associated :publisher
  validates :form_type,
    inclusion: { in: %w(irs_w_8ben irs_w_8ben_e irs_w_9) }
  validates :publisher_id, presence: true

  after_create :generate_docusign_envelope

  def self.find_using_after_sign_token(token)
    raise nil if token.blank?
    legal_form = find_by(after_sign_token: token)
    return nil if !legal_form
    return nil if legal_form.after_sign_token_expires_at < Time.zone.now

    # Currently after_sign_token is used only to trigger an on-demand update of
    # Docusign envelope status. To reduce chances of abuse, we could make these
    # tokens one time use. For now we'll be nice and let the user refresh.
    # legal_form.after_sign_token = nil
    # legal_form.after_sign_token_expires_at = nil
    # legal_form.save!
    legal_form
  end

  def generate_signing_url(return_url:)
    DocusignEnvelopeSigningUrlGenerator.new(
      name: name,
      email: email,
      envelope_id: docusign_envelope_id,
      return_url: return_url,
    ).perform
  end

  def generate_after_sign_token
    Rails.logger.info("PublisherLegalForm #{id} #after_sign_token already present") if after_sign_token
    self.after_sign_token = SecureRandom.hex(32)
    self.after_sign_token_expires_at = Time.zone.now + AFTER_SIGN_TOKEN_VALID_DURATION
    save!
    after_sign_token
  end

  def completed?
    status == "completed"
  end

  def encryption_key
    Rails.application.secrets[:attr_encrypted_key]
  end

  private

  def generate_docusign_envelope
    body = I18n.t("publisher_legal_forms.signing_request_body")
    subject = "[#{brave_publisher_id}] #{I18n.t("publisher_legal_forms.signing_request_subject_#{form_type}")}"
    template_id = Rails.application.secrets["docusign_template_id_#{form_type}".to_sym]
    generator = DocusignEnvelopeGenerator.new(
      email_body: body,
      email_subject: subject,
      signer_email: email,
      signer_name: name,
      signer_role: "Publisher",
      template_id: template_id,
    )
    generator.perform
    self.docusign_envelope_id = generator.envelope_id
    self.docusign_template_id = template_id
    self.status = generator.envelope_status
    save!
  end
end
