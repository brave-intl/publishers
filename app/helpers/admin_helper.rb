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
end
