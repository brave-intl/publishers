module PayoutHelper
  PREPARING = I18n.t(".publishers.payout_status.statuses.preparing")
  REVIEWING = I18n.t(".publishers.payout_status.statuses.reviewing")
  IN_PROGRESS = I18n.t(".publishers.payout_status.statuses.in_progress")
  DONE = I18n.t(".publishers.payout_status.statuses.done")

  def icon_class(statuses, current, index)
    selected = index <= statuses.find_index(current)

    return "inactive" unless selected
    return "animated" if statuses[index] == current && current != I18n.t(".publishers.payout_status.statuses.done")

    "active"
  end

  def current_status_and_percent(report_created_at)
    status = nil
    progress_percentage = nil

    status = DONE if !Rails.cache.fetch("payout_in_progress")
    days_ago = (Date.today - report_created_at.to_date) if status.blank?

    return [status, 1] if days_ago.blank?

    if days_ago < 3
      status = PREPARING
      progress_percentage = days_ago / 3.to_f
    elsif days_ago < 7
      status = REVIEWING
      progress_percentage = ((days_ago - 3.to_f) / 4)
    elsif days_ago < 11
      status = IN_PROGRESS
      progress_percentage = (((days_ago - 7.to_f) / 4))
    end

    [status, progress_percentage]
  end

  def percent_complete(created, selected_status, index)
    statuses = I18n.t(".publishers.payout_status.statuses").values
    selected = index <= statuses.find_index(selected_status)

    return 0 unless selected
    return current_status_and_percent(created).second if selected_status == statuses[index]
    100
  end

  def payout_warning(payout_report)
    found_payout = payout_report.potential_payments.where(publisher: current_publisher).first

    return I18n.t(".publishers.payout_status.information.not_found") if found_payout.blank?

    if found_payout.uphold_status.blank?
      I18n.t(".publishers.payout_status.information.connect_uphold")
    elsif found_payout.reauthorization_needed
      I18n.t(".publishers.payout_status.information.reauthorize_uphold")
    elsif found_payout.uphold_member.blank?
      I18n.t(".publishers.payout_status.information.kyc_required")
    end
  end

  def payout_amount(payout_report)
    amount = payout_report.potential_payments.
      where(publisher: current_publisher).
      select(&:amount).
      map { |x| x.amount.to_d }.
      sum

    (amount / 1E18).round(2)
  end
end
