module AdminHelper
  def sort_link(column, title = nil)
    title ||= column.titleize
    direction = column == sort_column && sort_direction == "asc" ? "desc" : "asc"
    icon = sort_direction == "asc" ? "fa fa-chevron-up" : "fa fa-chevron-down"
    icon = column == sort_column ? icon : ""
    link_to "#{title} <span class='#{icon}'></span>".html_safe, {column: column, direction: direction}.merge(params.permit(:type, :search))
  end

  def no_data_default(value)
    value || "--"
  end

  def nav_link(text, path)
    be_active = request.fullpath.start_with?(path) && path != '/admin'
    options =  be_active ? { class: "active" } : {}

    content_tag(:li) do
      link_to text, path, options
    end
  end

  def publisher_link(publisher)
    link = link_to(publisher.email || publisher.pending_email, admin_publisher_path(publisher))
    badge = nil
    badge = content_tag(:span, 'S', class: 'badge badge-danger ml-2', title: "Suspended") if publisher.suspended?

    link + badge
  end

  def payout_report_status_header(account_type)
    report_date = PayoutReport.most_recent_final_report.created_at.strftime("%b %d")

    if account_type == 'owner'
      "#{report_date}'s Payout Report Status (Referrals)"
    else account_type == 'channel'
      "#{report_date}'s Payout Report Status (Contributions)"
    end
  end
end
