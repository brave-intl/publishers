module PublishersHelper
  def publisher_humanize_verified(publisher)
    if publisher.verified?
      I18n.t("publishers.verified")
    else
      I18n.t("publishers.not_verified")
    end
  end

  def publisher_next_step_path(publisher)
    if publisher.verified?
      home_publishers_path
    else
      verification_publishers_path
    end
  end
end
