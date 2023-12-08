# typed: false

require "test_helper"

class GeminiGetValidationServiceTest < ActiveJob::TestCase
  it "sorts document types correctly" do
    ret = {"id" => "312fde", "countryCode" => "in", "validDocuments" => [{"type" => "national_identity_card", "issuingCountry" => "NIC"}, {"type" => "passport", "issuingCountry" => "PP"}, {"type" => "drivers_license", "issuingCountry" => "DL"}]}
    stub_request(:post, %r{.*v1/account/validate.*}).to_return(body: ret.to_json)
    gc = gemini_connections(:top_referrer_gemini_connected)
    res = Gemini::GetValidationService.perform(gc, 123)
    assert_equal "PP", res
  end

  it "relies on countryCode if validDocuments empty" do
    ret = {"id" => "312fde", "countryCode" => "in", "validDocuments" => []}
    stub_request(:post, %r{.*v1/account/validate.*}).to_return(body: ret.to_json)
    gc = gemini_connections(:top_referrer_gemini_connected)
    res = Gemini::GetValidationService.perform(gc, 123)
    assert_equal "in", res
  end

  it "returns nil if api blows up" do
    ret = {"error" => "Unable to find any Legal Id information for the given user"}
    stub_request(:post, %r{.*v1/account/validate.*}).to_return(body: ret.to_json)
    gc = gemini_connections(:top_referrer_gemini_connected)
    res = Gemini::GetValidationService.perform(gc, 123)
    assert_nil res
  end
end
