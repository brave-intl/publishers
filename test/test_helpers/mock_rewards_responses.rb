module MockRewardsResponses
  def stub_rewards_parameters
    body = {payoutStatus: {unverified: "complete", uphold: "complete", gemini: "complete", bitflyer: "complete"}, custodianRegions: {uphold: {allow: ["AU", "AT", "BE", "CA", "CO", "DK", "FI", "HK", "IE", "IT", "NL", "NO", "PT", "SG", "ES", "SE", "GB", "US"], block: []}, gemini: {allow: ["AU", "AT", "BE", "CA", "CO", "DK", "FI", "HK", "IE", "IT", "NL", "NO", "PT", "SG", "ES", "SE", "GB", "US"], block: []}, bitflyer: {allow: ["JP"], block: []}}, batRate: 0.330168, autocontribute: {choices: [1, 2, 3, 5, 7, 10, 20], defaultChoice: 1}, tips: {defaultTipChoices: [1.25, 5, 10.5], defaultMonthlyChoices: [1.25, 5, 10.5]}}

    stub_request(:get, "#{Rails.application.credentials[:api_rewards_base_uri]}/v1/parameters")
      .to_return(status: 200, body: body.to_json)
  end
end
