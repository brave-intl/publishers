module Admin::OrganizationHelper
  def boolean_to_image(value)
    if value
      image_tag("verified-icon@1x.png", alt: t(".https"), class: "https-check-icon", width: 11.5, height: 14)
    else
      image_tag("x.png", alt: t(".no_https_alt"), class: "https-check-icon", width: 12, height: 12)
    end
  end
end
