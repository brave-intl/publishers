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
end
