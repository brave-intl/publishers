# typed: true
# frozen_string_literal: true

module Ratio
  class Ratio < BaseApiClient
    extend T::Sig
    extend T::Helpers

    PATH = "/v1/"
    RATES_CACHE_KEY = "rates_cache"

    # FIXME: One day this should return BigDecimal
    RESULT_TYPE = T.type_alias { T::Hash[String, String] }

    sig { returns(RESULT_TYPE) }
    def all
      return JSON.parse(all_mock_response) if Rails.application.secrets[:bat_ratios_token].blank?
      response_to_return_value(get(PATH))
    end

    sig { params(currency: String).returns(RESULT_TYPE) }
    def relative(currency:)
      return JSON.parse(relative_mock_response) if Rails.application.secrets[:bat_ratios_token].blank?

      path = Addressable::Template.new("/v1/relative/{currency}")
      response_to_return_value(get(path.expand(currency: currency)))
    end

    # FIXME: This exact method is present in PublisherWalletGetter
    sig { params(currency: String).returns(RESULT_TYPE) }
    def self.relative_cached(currency:)
      # Cache the ratios every minute. Rates are used for display purposes only.
      Rails.cache.fetch(RATES_CACHE_KEY, expires_in: 10.minutes) do
        Ratio.new.relative(currency: "BAT")
      end
    end

    # FIXME: There is no error handling here for failed responses that I can tell
    # see app/services/base_api_client.rb
    sig { params(response: ActionDispatch::Response).returns(RESULT_TYPE) }
    def response_to_return_value(response)
      JSON.parse(response.body)

      #      out = {}
      #
      #      parsed.each do |key|
      #        out[key] = BigDecimal(parsed[key])
      #      end
      #
      #      out
    end

    def api_base_uri
      Rails.application.secrets[:bat_ratios_url]
    end

    def api_authorization_header
      "Bearer #{Rails.application.secrets[:bat_ratios_token]}"
    end

    # FIXME: This really shouldn't be here.
    def relative_mock_response
      <<-JSON
      {
        "lastUpdated": "2019-10-30T16:27:11.454Z",
        "payload": {
          "BTC": "0.00005418424016883016",
          "BAT": "1",
          "ETH": "0.000795331082073117",
          "USD": "0.2363863335301452",
          "EUR": "0.20187818378874756",
          "GBP": "0.1799810085548496"
        }
      }
      JSON
    end

    def all_mock_response
      <<-JSON
      {
        "lastUpdated": "2019-10-29T23:31:49.874Z",
        "payload": {
          "AED": "3.6752201564212312616592",
          "AFN": "78.25001",
          "ALL": "111.183058",
          "AMD": "475.606515",
          "ANG": "1.754633",
          "AOA": "497.3485",
          "ARS": "59.4388235665617045231824",
          "AUD": "1.45893101915753747496848",
          "AWG": "1.8",
          "AZN": "1.7025",
          "BAM": "1.764561",
          "BBD": "2",
          "BDT": "84.640914",
          "BGN": "1.75852",
          "BHD": "0.377022",
          "BIF": "1867.95523",
          "BMD": "1",
          "BND": "1.362539",
          "BOB": "6.913413",
          "BRL": "4.0006756155614217018712",
          "BSD": "1",
          "BTC": "0.00010613700399999999997936",
          "BTN": "70.803938",
          "BWP": "10.843968",
          "BYN": "2.056938",
          "BZD": "2.009572",
          "CAD": "1.30986691539700197956992",
          "CDF": "1658.656578",
          "CHF": "0.99476799431092674629472",
          "CLF": "0.025181",
          "CLP": "728.099425",
          "CNH": "7.065245",
          "CNY": "7.0702634379485245578784",
          "COP": "3372.65564",
          "CRC": "581.182283",
          "CUC": "1",
          "CUP": "25.75",
          "CVE": "99.63",
          "CZK": "22.984499",
          "DJF": "178.05",
          "DKK": "6.700000000000000000000",
          "DOP": "52.908952",
          "DZD": "119.725743",
          "EGP": "16.1314",
          "ERN": "14.999717",
          "ETB": "29.614388",
          "EUR": "0.90037840642255114529488",
          "FJD": "2.18635",
          "FKP": "0.777158",
          "GBP": "0.7776909541698878097856",
          "GEL": "2.965",
          "GGP": "0.777158",
          "GHS": "5.498851",
          "GIP": "0.777158",
          "GMD": "51.15",
          "GNF": "9259.374274",
          "GTQ": "7.735419",
          "GYD": "208.950777",
          "HKD": "7.84454223803488262315632",
          "HNL": "24.725952",
          "HRK": "6.709438",
          "HTG": "96.736679",
          "HUF": "296.74",
          "IDR": "14005.388",
          "ILS": "3.52770703178957292285504",
          "IMP": "0.777158",
          "INR": "71.10494835919901950158688",
          "IQD": "1189.043777",
          "IRR": "42105",
          "ISK": "124.269972",
          "JEP": "0.777158",
          "JMD": "137.4043",
          "JOD": "0.7086",
          "JPY": "108.935270538003205409192",
          "KES": "103.4630159186461770327696",
          "KGS": "69.653151",
          "KHR": "4050.418995",
          "KMF": "443.099924",
          "KPW": "900",
          "KRW": "1166.75",
          "KWD": "0.303723",
          "KYD": "0.833172",
          "KZT": "388.543595",
          "LAK": "8837.47492",
          "LBP": "1511.105134",
          "LKR": "181.507428",
          "LRD": "211.600076",
          "LSL": "14.631758",
          "LYD": "1.402749",
          "MAD": "9.637341",
          "MDL": "17.467339",
          "MGA": "3693.014259",
          "MKD": "55.335074",
          "MMK": "1528.620484",
          "MNT": "2675.815473",
          "MOP": "8.073562",
          "MRO": "357",
          "MRU": "37.2",
          "MUR": "36.46",
          "MVR": "15.45",
          "MWK": "732.145234",
          "MXN": "19.1317778389629489922256",
          "MYR": "4.1831",
          "MZN": "62.669001",
          "NAD": "14.631758",
          "NGN": "361.205645",
          "NIO": "33.894024",
          "NOK": "9.2340294174865654738336",
          "NPR": "113.286367",
          "NZD": "1.57483418851098331260032",
          "OMR": "0.385004",
          "PAB": "1",
          "PEN": "3.33494",
          "PGK": "3.38",
          "PHP": "51.11233707844140660833136",
          "PKR": "155.685082",
          "PLN": "3.84133502428245498181168",
          "PYG": "6472.608752",
          "QAR": "3.641",
          "RON": "4.2795",
          "RSD": "105.732983",
          "RUB": "63.9755",
          "RWF": "918.212353",
          "SAR": "3.750312",
          "SBD": "8.302329",
          "SCR": "13.743645",
          "SDG": "45.09967",
          "SEK": "9.7090292836013953030992",
          "SGD": "1.36329064164909965090864",
          "SHP": "0.777158",
          "SLL": "7438.043346",
          "SOS": "579.442618",
          "SRD": "7.458",
          "SSP": "130.26",
          "STD": "21560.79",
          "STN": "22.2",
          "SVC": "8.748686",
          "SYP": "514.989787",
          "SZL": "14.63411",
          "THB": "30.25",
          "TJS": "9.694558",
          "TMT": "3.5",
          "TND": "2.8325",
          "TOP": "2.321369",
          "TRY": "5.750692",
          "TTD": "6.758421",
          "TWD": "30.446998",
          "TZS": "2302.522617",
          "UAH": "25.08113",
          "UGX": "3699.220586",
          "USD": "1",
          "UYU": "37.508992",
          "UZS": "9452.084832",
          "VEF": "248487.642241",
          "VES": "21643.876304",
          "VND": "23136.719677",
          "VUV": "116.084426",
          "WST": "2.645513",
          "XAF": "590.287525",
          "XAG": "0.056090159564146318458028",
          "XAU": "0.00067739763927481851594256",
          "XCD": "2.70255",
          "XDR": "0.726916",
          "XOF": "590.287525",
          "XPD": "0.00056874904971773357205872",
          "XPF": "107.385147",
          "XPT": "0.00107719002711454699705648",
          "YER": "250.350066",
          "ZAR": "14.62755",
          "ZMW": "13.26233",
          "ZWL": "322.000001",
          "ADA": "23.1734992166015781985669928",
          "ATOM": "0.31910747167308456673345696",
          "BAT": "4.269270825368113525534228251707255744",
          "BCH": "0.0034722420168775337034824",
          "BTG": "0.11884889898449589891155376",
          "DASH": "0.01373521100109512585760992",
          "DCR": "0.064012410859696426875456",
          "DGB": "136.1403668094861786743833009776",
          "DOGE": "379.0271575946342740056737831792",
          "EOS": "0.29454080280229508809205728",
          "ETH": "0.005252935566432770491268934246539776",
          "IOTA": "3.5662972937162590735027632",
          "LBA": "63.938127543116833737632343657437625584",
          "LINK": "0.37622117739912020356594416",
          "LTC": "0.01672178641797793909357104",
          "NANO": "1.156117854035561421477824",
          "NEO": "0.093261875966927500688944",
          "TRX": "45.9426857690253531465290996304",
          "UPBTC": "0.000106066959781276515488",
          "UPEUR": "0.90037840642255114529488",
          "UPUSD": "1.000631696049778448",
          "VOX": "324.88042080006089104646649664",
          "XEM": "23.84727587996421834173755968",
          "XLM": "15.05388439599852625331841216",
          "XRP": "3.315325956198095596602384",
          "ZIL": "179.9697295053421582717806145392",
          "ZRX": "3.568713919325388893432528",
          "BCC": "0.0034722420168775337034824"
        }
      }
      JSON
    end
  end
end
