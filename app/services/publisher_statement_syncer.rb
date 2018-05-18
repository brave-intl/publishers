class PublisherStatementSyncer
  attr_reader :publisher_statement

  def initialize(publisher_statement:)
    @publisher_statement = publisher_statement
  end

  def perform
    return if publisher_statement.contents.present?

    contents = PublisherStatementGetter.new(publisher_statement: publisher_statement).perform
    if contents
      publisher_statement.contents = contents
      publisher_statement.save!

      # TODO uncomment when statement notification emails are sending
      # PublisherMailer.statement_ready(publisher_statement).deliver_later
    end
  end
end
