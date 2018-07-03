module Admin::FaqHelper
  def categories_select_options(faq_category_id)
    options_from_collection_for_select(FaqCategory.includes(:faqs).all, :id, :name, faq_category_id)
  end
end
