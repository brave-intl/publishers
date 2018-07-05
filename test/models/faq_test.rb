require "test_helper"

class FaqTest < ActiveSupport::TestCase
  test "faqs require a question" do
    f = Faq.new(faq_category: faq_categories(:brave_payments), question: nil, answer: "A", rank: 1)
    refute f.valid?
    f.question = "Why?"
    assert f.valid?
  end

  test "faqs require an answer" do
    f = Faq.new(faq_category: faq_categories(:brave_payments), question: "Q", answer: nil, rank: 1)
    refute f.valid?
    f.answer = "A"
    assert f.valid?
  end

  test "faqs require a rank" do
    f = Faq.new(faq_category: faq_categories(:brave_payments), question: "Q", answer: "A", rank: nil)
    refute f.valid?
    f.rank = 1
    assert f.valid?
  end

  test "faqs require an faq_category" do
    f = Faq.new(faq_category: nil, question: "Q", answer: "A", rank: 1)
    refute f.valid?
    f.faq_category = faq_categories(:brave_payments)
    assert f.valid?
  end

  test "faqs are sorted by rank" do
    faqs = faq_categories(:verification).faqs
    assert_equal 1, faqs.first.rank
    assert_equal 100, faqs.last.rank
  end
end
