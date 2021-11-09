# typed: ignore
# Generated by the protocol buffer compiler.  DO NOT EDIT!
# source: channel_responses.proto

require 'google/protobuf'

Google::Protobuf::DescriptorPool.generated_pool.build do
  add_file("channel_responses.proto", :syntax => :proto3) do
    add_message "publishers_pb.SocialLinks" do
      optional :youtube, :string, 1
      optional :twitter, :string, 2
      optional :twitch, :string, 3
    end
    add_message "publishers_pb.SiteBannerDetails" do
      optional :title, :string, 1
      optional :description, :string, 2
      optional :background_url, :string, 3
      optional :logo_url, :string, 4
      repeated :donation_amounts, :double, 5
      optional :social_links, :message, 6, "publishers_pb.SocialLinks"
    end
    add_message "publishers_pb.UpholdWallet" do
      optional :wallet_state, :enum, 1, "publishers_pb.UpholdWalletState"
      optional :address, :string, 2
    end
    add_message "publishers_pb.PaypalWallet" do
      optional :wallet_state, :enum, 1, "publishers_pb.PaypalWalletState"
    end
    add_message "publishers_pb.BitflyerWallet" do
      optional :wallet_state, :enum, 1, "publishers_pb.BitflyerWalletState"
      optional :address, :string, 2
    end
    add_message "publishers_pb.GeminiWallet" do
      optional :wallet_state, :enum, 1, "publishers_pb.GeminiWalletState"
      optional :address, :string, 2
    end
    add_message "publishers_pb.Wallet" do
      oneof :provider do
        optional :uphold_wallet, :message, 1, "publishers_pb.UpholdWallet"
        optional :paypal_wallet, :message, 2, "publishers_pb.PaypalWallet"
        optional :bitflyer_wallet, :message, 3, "publishers_pb.BitflyerWallet"
        optional :gemini_wallet, :message, 4, "publishers_pb.GeminiWallet"
      end
    end
    add_message "publishers_pb.ChannelResponse" do
      optional :channel_identifier, :string, 1
      repeated :wallets, :message, 2, "publishers_pb.Wallet"
      optional :site_banner_details, :message, 3, "publishers_pb.SiteBannerDetails"
    end
    add_message "publishers_pb.ChannelResponseList" do
      repeated :channel_responses, :message, 1, "publishers_pb.ChannelResponse"
    end
    add_enum "publishers_pb.UpholdWalletState" do
      value :UPHOLD_ACCOUNT_NO_KYC, 0
      value :UPHOLD_ACCOUNT_KYC, 1
    end
    add_enum "publishers_pb.PaypalWalletState" do
      value :PAYPAL_ACCOUNT_NO_KYC, 0
      value :PAYPAL_ACCOUNT_KYC, 1
    end
    add_enum "publishers_pb.BitflyerWalletState" do
      value :BITFLYER_ACCOUNT_NO_KYC, 0
      value :BITFLYER_ACCOUNT_KYC, 1
    end
    add_enum "publishers_pb.GeminiWalletState" do
      value :GEMINI_ACCOUNT_NO_KYC, 0
      value :GEMINI_ACCOUNT_KYC, 1
    end
  end
end

module PublishersPb
  SocialLinks = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("publishers_pb.SocialLinks").msgclass
  SiteBannerDetails = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("publishers_pb.SiteBannerDetails").msgclass
  UpholdWallet = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("publishers_pb.UpholdWallet").msgclass
  PaypalWallet = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("publishers_pb.PaypalWallet").msgclass
  BitflyerWallet = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("publishers_pb.BitflyerWallet").msgclass
  GeminiWallet = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("publishers_pb.GeminiWallet").msgclass
  Wallet = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("publishers_pb.Wallet").msgclass
  ChannelResponse = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("publishers_pb.ChannelResponse").msgclass
  ChannelResponseList = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("publishers_pb.ChannelResponseList").msgclass
  UpholdWalletState = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("publishers_pb.UpholdWalletState").enummodule
  PaypalWalletState = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("publishers_pb.PaypalWalletState").enummodule
  BitflyerWalletState = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("publishers_pb.BitflyerWalletState").enummodule
  GeminiWalletState = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("publishers_pb.GeminiWalletState").enummodule
end
