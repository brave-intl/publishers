module PayoutHelper
  def icon_class(statuses, current, index)
    selected = index <= statuses.find_index(current)

    return 'inactive' unless selected
    return "animated" if  statuses[index] == current && current != I18n.t(".publishers.payout_status.statuses.done")

    "active"
  end

  def current_status_and_percent(report_created_at)
    today = DateTime.now

    difference = (today.to_time - report_created_at.to_time) / 1.day

    transitions = {
      3 => "preparing",
      7 => "reviewing",
      11 => "in_progress",
    }

    current = transitions.keys.detect { |k| difference < k }

    status = transitions[current]
    status = 'done' if status.blank? || !Rails.cache.fetch('payout_in_progress')

    if current.present?
      transition_index = transitions.keys.find_index(current) - 1
      base = transitions.keys[transition_index]
      base = 0 if transition_index < 0

      percent = ((difference - base).to_f / (current - base).to_f).to_f
    end

    [
      I18n.t(".publishers.payout_status.statuses.#{status}"),
      percent
    ]
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

    return I18n.t('.publishers.payout_status.information.not_found') if found_payout.blank?

    if found_payout.uphold_status.blank?
      I18n.t('.publishers.payout_status.information.connect_uphold')
    elsif found_payout.reauthorization_needed
      I18n.t('.publishers.payout_status.information.reauthorize_uphold')
    elsif found_payout.uphold_member.blank?
      I18n.t('.publishers.payout_status.information.kyc_required')
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
