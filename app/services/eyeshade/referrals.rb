# frozen_string_literal: true

class Eyeshade::Referrals < Eyeshade::BaseApiClient
  PATH = "/v1/referrals"

  def groups
    return offline_groups if Rails.application.secrets[:api_eyeshade_offline]

    response = connection.get do |request|
      request.headers["Authorization"] = api_authorization_header
      request.url(PATH + "/groups")
      request.params = 'name, amount, currency, activeAt'
    end

    JSON.parse(response.body)
  end

  private

  def offline_groups
    [
      {
        id: "e48f310b-0e81-4b39-a836-4dda32d7df74",
        name: "Group 1",
        amount: "7.500000000000000000",
        currency: "USD",
        activeAt: "2019-10-01T00:00:00.000Z",
      },
      {
        id: "6491bbe5-4d50-4c05-af5c-a2ac4a04d14e",
        name: "Group 2",
        amount: "6.500000000000000000",
        currency: "USD",
        activeAt: "2019-10-01T00:00:00.000Z",
      },
      {
        id: "bda04a7e-ffe9-487c-b472-4b6d30cb5b16",
        name: "Group 3",
        amount: "5.000000000000000000",
        currency: "USD",
        activeAt: "2019-10-01T00:00:00.000Z",
      },
      {
        id: "cf70e666-0930-485e-8c66-05e5969622d3",
        name: "Group 4",
        amount: "2.000000000000000000",
        currency: "USD",
        activeAt: "2019-10-01T00:00:00.000Z",
      },
      {
        id: "211e57d3-a490-4cf3-b885-47a85f2e1dc0",
        name: "Group 5",
        amount: "1.000000000000000000",
        currency: "USD",
        activeAt: "2019-10-01T00:00:00.000Z",
      },
    ]
  end
end
