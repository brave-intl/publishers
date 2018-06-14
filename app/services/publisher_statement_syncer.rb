class PublisherStatementSyncer
  attr_reader :publisher_statement

  def initialize(publisher_statement:, send_email:)
    @publisher_statement = publisher_statement
    @send_email = send_email
  end

  def perform
    return if publisher_statement.contents.present?

    contents = PublisherStatementGetter.new(publisher_statement: publisher_statement).perform
    if contents.present?
      publisher_statement.contents = contents
      publisher_statement.save!

      PublisherMailer.statement_ready(publisher_statement).deliver_later if @send_email
    end
  end
end
