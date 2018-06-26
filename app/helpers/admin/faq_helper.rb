module Admin::FaqHelper
  def markdown
    @renderer ||= Redcarpet::Render::HTML.new(hard_wrap: true)

    @markdown ||= Redcarpet::Markdown.new(@renderer,
                                          lax_spacing: true,
                                          underline: true,
                                          quote: true,
                                          autolink: true,
                                          tables: true)
  end

  def categories_select_options(faq_category_id)
    options_from_collection_for_select(FaqCategory.includes(:faqs).all, :id, :name, faq_category_id)
  end
end
