module AdminHelper
  def sort_link(column, title = nil)
    title ||= column.titleize
    direction = column == sort_column && sort_direction == "asc" ? "desc" : "asc"
    icon = sort_direction == "asc" ? "fa fa-chevron-up" : "fa fa-chevron-down"
    icon = column == sort_column ? icon : ""
    link_to "#{title} <span class='#{icon}'></span>".html_safe, {column: column, direction: direction}.merge(params.permit(:type, :q, :status))
  end

  def set_mentions(note)
    formatted_note = note.lines.map do |line|
      line = line.split(" ").map do |word|
        if word.starts_with?("@")
          publisher = Publisher.where("email LIKE ?", "#{word[1..-1]}@brave.com").first
          # Assuming the administrator is a brave.com email address :)
          word = link_to("@#{publisher.name}", admin_publisher_url(publisher)) if publisher.present?
        end

        # Format for link
        if word.starts_with?("http://") || word.starts_with?("https://")
          # If the link is another publisher
          if word.include?('admin/publishers/')
            publisher_id = word.sub("#{root_url}admin/publishers/", "")
            publisher = Publisher.find_by(id: publisher_id)
            word = link_to(publisher.name, admin_publisher_url(publisher)) if publisher
          end

          word = link_to(word)
        end

        word
      end

      line.join(" ") + "\r\n"
    end

    formatted_note.join
  end

  def no_data_default(value)
    value || "--"
  end

  def nav_link(text, path, &block)
    be_active = request.fullpath.start_with?(path) && path != '/admin'
    options =  be_active ? { class: "active w-100" } : { class: 'w-100'}

    text = content_tag(:span) do
      concat text
      block&.call
    end

    content_tag(:li) do
      link_to(text, path, options)
    end
  end

  def case_link(text, path, badge= nil)
    be_active = request.fullpath.eql?(path)

    options =  be_active ? { class: "active" } : { class: "text-muted"}
    badge_class = be_active ? "badge-primary" : "badge-dark"

    concat link_to(text, path, options)
    content_tag(
      :div,
      content_tag(:div, badge, class: "badge badge-pill #{badge_class}")
    )
  end

  def percentage_difference(x,y)
    numerator = (x-y).to_f
    denominator = y

    value = (numerator / denominator) * 100

    return if value.zero?

    icon = value.positive? ? 'level-up' : 'level-down'
    class_name = value.positive? ? 'text-success' : 'text-danger'

    content_tag :div, class: class_name do
      fa_icon icon, text: number_to_percentage(value), right: true, class: class_name
    end
  end

  def publisher_link(publisher)
    link = link_to(publisher.email || publisher.pending_email, admin_publisher_path(publisher))
    badge = nil
    badge = content_tag(:span, 'S', class: 'badge badge-danger ml-2', title: "Suspended") if publisher.suspended?

    link + badge
  end

  def payout_report_status_header(account_type)
    report_date = PayoutReport.most_recent_final_report.created_at
    report_date = report_date.strftime("%B #{report_date.day.ordinalize}")

    if account_type == 'owner'
      "#{report_date} Payout (Referrals)"
    else account_type == 'channel'
      "#{report_date} Payout Contributions"
    end
  end
end
