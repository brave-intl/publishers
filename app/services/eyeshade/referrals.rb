# frozen_string_literal: true

class Eyeshade::Referrals < Eyeshade::BaseApiClient
  PATH = "/v1/referrals"

  def groups
    return offline_groups if Rails.application.secrets[:api_eyeshade_offline]

    response = connection.get do |request|
      request.headers["Authorization"] = api_authorization_header
      request.url(PATH + "/groups")
      request.params = {
        fields: 'name, amount, currency, activeAt, codes',
      }
    end

    JSON.parse(response.body)
  end

  def statement(publisher:, start_date:, end_date:)
    return offline_statement if Rails.application.secrets[:api_eyeshade_offline]

    response = connection.get do |request|
      request.headers["Authorization"] = api_authorization_header
      request.url(PATH + "/statement/#{URI.escape(publisher.owner_identifier)}")
      request.params = {
        start: start_date,
        until: end_date,
      }
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
        codes: ["US"],
      },
      {
        id: "6491bbe5-4d50-4c05-af5c-a2ac4a04d14e",
        name: "Group 2",
        amount: "6.500000000000000000",
        currency: "USD",
        activeAt: "2019-10-01T00:00:00.000Z",
        codes: ["AU", "CA", "FR", "DE", "IE", "JP", "NZ", "GB"],
      },
      {
        id: "bda04a7e-ffe9-487c-b472-4b6d30cb5b16",
        name: "Group 3",
        amount: "5.000000000000000000",
        currency: "USD",
        activeAt: "2019-10-01T00:00:00.000Z",
        codes: ["AT", "BE", "DK", "FI", "HK", "IL", "IT", "LU", "MT", "NL", "NO", "PT", "KR", "SG", "ES", "SE", "CH", "TW"],
      },
      {
        id: "cf70e666-0930-485e-8c66-05e5969622d3",
        name: "Group 4",
        amount: "2.000000000000000000",
        currency: "USD",
        activeAt: "2019-10-01T00:00:00.000Z",
        codes: ["AL", "AR", "AM", "AZ", "BY", "BZ", "BO", "BA", "BR", "BG", "CL", "CO", "CR", "HR", "CZ", "EC", "SV", "EE", "GE", "GT", "HN", "HU", "LV", "LT", "MK", "MX", "ME", "NI", "PA", "PY", "PE", "PL", "MD", "RO", "RU", "SA", "RS", "SK", "TR", "UA", "UY"],
      },
      {
        "id": "211e57d3-a490-4cf3-b885-47a85f2e1dc0",
        "name": "Group 5",
        "amount": "1.000000000000000000",
        "currency": "USD",
        "activeAt": "2019-10-01T00:00:00.000Z",
        "codes": ["AF", "DZ", "AD", "AO", "AG", "BS", "BH", "BD", "BB", "BJ", "BT", "BW", "BN", "BF", "BI", "CI", "CV", "KH", "CM", "TD", "CN", "KM", "CD", "CY", "CG", "DJ", "DM", "DO", "EG", "GQ", "ER", "SZ", "ET", "FJ", "GA", "GM", "GH", "GR", "GD", "GN", "GW", "GY", "HT", "VA", "IS", "IN", "ID", "IQ", "JM", "JO", "KZ", "KE", "KI", "KW", "KG", "LA", "LB", "LS", "LR", "LI", "MG", "MW", "MY", "MV", "ML", "MH", "MR", "MU", "FM", "MD", "MC", "MN", "MA", "MZ", "MM", "NA", "NR", "NP", "NE", "NG", "MK", "OM", "PK", "PW", "PS", "PG", "PH", "QA", "RO", "RW", "KN", "LC", "VC", "WS", "SM", "ST", "SA", "SN", "SC", "SL", "SI", "SB", "ZA", "LK", "SS", "SR", "TJ", "TZ", "TH", "TL", "TG", "TO", "TT", "TN", "TM", "TV", "UG", "AE", "UZ", "VU", "VE", "VN", "YE", "ZM", "ZW"],
      },
    ]
  end

  def offline_statement
    [
      {
        publisher: 'youtube#channel:UCFNTTISby1c_H-rm5Ww5rZg',
        groupId: 'e48f310b-0e81-4b39-a836-4dda32d7df74',
        groupRate: '1',
        payoutRate: '4.932881498931005799',
        amount: '32.063729743051537694',
      },
      {
        publisher: 'youtube#channel:UCFNTTISby1c_H-rm5Ww5rZg',
        groupId: 'e48f310b-0e81-4b39-a836-4dda32d7df74',
        groupRate: '1',
        payoutRate: '4.932881498931005799',
        amount: '32.063729743051537694',
      },
      {
        publisher: 'youtube#channel:UCFNTTISby1c_H-rm5Ww5rZg',
        groupId: '211e57d3-a490-4cf3-b885-47a85f2e1dc0',
        groupRate: '1',
        payoutRate: '4.932881498931005799',
        amount: '32.063729743051537694',
      },
    ]
  end
end
