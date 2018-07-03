require "test_helper"

class FaqCategoryTest < ActiveSupport::TestCase
  test "faq categories without published faqs are excluded from ready_for_display" do
    all_categories_count = FaqCategory.count
    ready_for_display_categories_count = FaqCategory.ready_for_display.count
    assert_equal all_categories_count - 2, ready_for_display_categories_count
  end

  test "faq categories require a name" do
    c = FaqCategory.new(name: nil, rank: 1)
    refute c.valid?
    c.name = "General"
    assert c.valid?
  end

  test "faq categories require a rank" do
    c = FaqCategory.new(name: "General", rank: nil)
    refute c.valid?
    c.rank = 2
    assert c.valid?
  end

  test "faqs categories are sorted by rank" do
    faq_categories = FaqCategory.all
    assert_equal 0, faq_categories.first.rank
    assert_equal 100, faq_categories.last.rank
  end
end
