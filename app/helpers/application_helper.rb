module ApplicationHelper
  def popover_menu(&block)
    render(layout: "popover", &block)
  end
end
