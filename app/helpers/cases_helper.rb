module CasesHelper
  def case_badge(status)
    label = case status
    when Case::REJECTED
      "badge-danger"
      "badge-danger"
    when Case::OPEN
      "badge-dark"
    when Case::ACCEPTED
      "badge-success"
    when Case::ASSIGNED
      "badge-primary"
    else
      "badge-secondary"
    end

    content_tag(:span, status, class: "badge #{label}")
  end

  def status_query
    search_params = params[:q].split(' ')
    index = search_params.index { |x| x.include?("status") }
    status = nil
    status = search_params[index].split(':')[1].gsub('"', "") if index.present?

    status.present? ? status : 'All'
  end
end
