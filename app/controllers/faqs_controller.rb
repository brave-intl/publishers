class FaqsController < ApplicationController
  layout 'faqs'

  def index
    @faq_categories = FaqCategory.ready_for_display.includes(:faqs).all
  end
end
