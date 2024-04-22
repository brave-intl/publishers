require "json"
require "base64"

class ParseOfacListService
  # produces
  # {:addresses=>
  #   ["0x4f47bc496083c727c5fbe3ce9cdf2b0f6496270c",
  #    "18M8bJWMzWHDBMxoLqjHHAffdRy4SrzkfB",
  #    "qpf2cphc5dkuclkqur7lhj2yuqq9pk3hmukle77vhq",
  #    "qpusmp64rajses77x95g9ah825mtyyv74smwwkxhx3", etc...
  def self.perform
    fetch_github_repo_top_level_files(repo_owner: "brave-intl", repo_name: "ofac-sanctioned-digital-currency-addresses", branch: "lists")
  end

  def self.fetch_github_file_content(repo_owner:, repo_name:, branch:, file_path:, github_headers:)
    uri = URI("https://api.github.com/repos/#{repo_owner}/#{repo_name}/contents/#{file_path}?ref=#{branch}")
    https = Net::HTTP.new(uri.host, uri.port)
    https.use_ssl = true

    request = Net::HTTP::Get.new(uri)
    request.add_field("Authorization", github_headers[:Authorization])
    request.add_field("Accept", github_headers[:Accept])

    response = https.request(request)
    content_data = JSON.parse(response.body)

    return "" if content_data["content"].nil?

    Base64.decode64(content_data["content"]).force_encoding("utf-8")
  end

  def self.fetch_github_repo_top_level_files(repo_owner:, repo_name:, branch:)
    github_token = Rails.configuration.pub_secrets[:github_ofac_token]
    github_headers = {
      Accept: "application/vnd.github.v3+json",
      Authorization: "token #{github_token}"
    }

    uri = URI("https://api.github.com/repos/#{repo_owner}/#{repo_name}/git/trees/#{branch}?recursive=1")
    response = Net::HTTP.get(uri, github_headers)
    data = JSON.parse(response)

    return if data["tree"].nil?

    banned_addresses = []
    data["tree"].each do |item|
      next unless item["type"] == "blob" && !item["path"].include?("/") && item["path"].end_with?(".json") && item["path"] != "README.md"

      content = fetch_github_file_content(repo_owner:, repo_name:, branch:, file_path: item["path"], github_headers:)
      banned_addresses += JSON.parse(content)
    end

    banned_addresses = banned_addresses.uniq

    {addresses: banned_addresses}
  end
end
