# typed: ignore

class Api::V3::Public::OfacController < Api::V3::Public::BaseController
  def banned_lists
    render(json: {addresses: OfacAddress.pluck(:address)}.to_json, status: 200)
  end

  def banned_lists_fresh
    render(json: ParseOfacListService.perform.to_json, status: 200)
  end
end
