# typed: true

module ApplicationHelper
  def popover_menu(&)
    render(layout: "popover", &)
  end
end
