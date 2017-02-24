# Get envelope field data from signer data (docusign calls them "tabs")
class DocusignEnvelopeFieldsGetter
  attr_reader :signer

  # Get recipient from DocusignEnvelopeRecipientsGetter
  def initialize(signer:)
    @signer = signer
  end

  def perform
    tabs = signer["tabs"]
    result = {}
    result.merge!(checkbox_tabs(tabs)) if tabs["checkboxTabs"].present?
    result.merge!(radio_tabs(tabs)) if tabs["radioGroupTabs"].present?
    signer["tabs"].each do |category, tabs|
      next if %w(checkboxTabs radioGroupTabs).include?(category)
      tabs.each do |tab|
        result[tab["tabLabel"]] = tab["value"]
      end
    end
    result
  end

  # Get hash of checkbox selections from signer tabs.
  # @returns {"{groupName}" => "{true|false}"}
  def checkbox_tabs(all_tabs)
    tabs = all_tabs["checkboxTabs"] or return {}
    result = {}
    tabs.each do |tab|
      name = tab["tabLabel"]
      result[name] = (tab["selected"] == "true")
    end
    result
  end

  # Get hash of radio selections from signer tabs.
  # @returns {"{groupName}" => "{value}"}
  def radio_tabs(all_tabs)
    tabs = all_tabs["radioGroupTabs"] or return {}
    result = {}
    tabs.each do |tab|
      name = tab["groupName"]
      tab_selected = tab["radios"].find do |tab|
        tab["selected"] == "true"
      end
      result[name] = tab_selected && tab_selected["value"]
    end
    result
  end
end
