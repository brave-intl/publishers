# typed: false
require "test_helper"

class Oauth2ConfigTest < ActiveSupport::TestCase
  [Oauth2::Config::Gemini, Oauth2::Config::Uphold, Oauth2::Config::Bitflyer].each do |cls|
    describe cls.name do
      [:scope, :client_id, :client_secret, :authorization_url, :token_url, :redirect_uri, :content_type].each do |method|
        let(:klass) { cls }
        let(:token_url_values) do
          case klass.name
          when "Oauth2::Config::Gemini"
            "api.sandbox"
          when "Oauth2::Config::Bitflyer"
            "azurewebsites"
          when "Oauth2::Config::Uphold"
            "api-sandbox"
          end
        end
        let(:auth_url_values) do
          case klass.name
          when "Oauth2::Config::Gemini"
            "exchange.sandbox"
          when "Oauth2::Config::Bitflyer"
            "azurewebsites"
          when "Oauth2::Config::Uphold"
            "sandbox.uphold"
          end
        end
        it "should implement #{method}" do
          assert klass.send(method)
        end
      end

      ["development", "staging", "production"].each do |environment|
        describe "when #{environment}" do
          let(:redirect_url_values) do
            case environment
            when "production"
              "creators.brave"
            when "staging"
              "publishers"
            else
              "localhost"
            end
          end

          before do
            klass.expects(:env).returns(environment).at_least_once
          end

          describe "external urls" do
            describe "token_url" do
              if environment != "production"
                it "should include" do
                  assert_includes(klass.token_url.to_s, token_url_values)
                end
              else
                it "should not include" do
                  refute_includes(klass.token_url.to_s, token_url_values)
                end
              end
            end

            describe "authorization_url" do
              if environment != "production"
                it "should include" do
                  assert_includes(klass.authorization_url.to_s, auth_url_values)
                end
              else
                it "should not include" do
                  refute_includes(klass.authorization_url.to_s, auth_url_values)
                end
              end
            end

            describe "base_redirect_url" do
              it "should include" do
                assert_includes(klass.base_redirect_url.to_s, redirect_url_values)
              end
            end
          end
        end
      end
    end
  end
end
