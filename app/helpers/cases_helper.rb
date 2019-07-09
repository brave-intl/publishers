module CasesHelper
  def case_badge(status)
    label = case status
    when Case::CLOSED
      "badge-dark"
    when Case::OPEN
      "badge-secondary text-white"
    when Case::RESOLVED
      "badge-success"
    when Case::IN_PROGRESS
      "badge-primary"
    else
      "badge-secondary"
    end

    content_tag(:span, status.sub('_', ' ').titleize, class: "badge #{label}")
  end

  def status_query
    search_params = params[:q].split(' ')
    index = search_params.index { |x| x.include?("status") }
    status = nil
    status = search_params[index].split(':')[1].gsub('"', "") if index.present?

    status.present? ? status : 'All'
  end
end
