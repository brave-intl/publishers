module Admin::OrganizationHelper
  def boolean_to_image(value)
    if value
      image_tag("verified-icon@1x.png", class: "https-check-icon", width: 11.5, height: 14)
    else
      image_tag("x.png", class: "https-check-icon", width: 12, height: 12)
    end
  end
end
