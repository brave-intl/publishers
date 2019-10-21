class PaypalConnectionDecorator < Draper::Decorator
  delegate_all

  def status_summary
    "Connected"
  end
end
