# This is an autogenerated file for dynamic methods in Channel
# Please rerun bundle exec rake rails_rbi:models[Channel] to regenerate.

# typed: ignore
module Channel::ActiveRelation_WhereNot
  sig { params(opts: T.untyped, rest: T.untyped).returns(T.self_type) }
  def not(opts, *rest); end
end

module Channel::GeneratedAttributeMethods
  sig { returns(T.nilable(ActiveSupport::TimeWithZone)) }
  def contest_timesout_at; end

  sig { params(value: T.nilable(T.any(Date, Time, ActiveSupport::TimeWithZone))).void }
  def contest_timesout_at=(value); end

  sig { returns(T::Boolean) }
  def contest_timesout_at?; end

  sig { returns(T.nilable(String)) }
  def contest_token; end

  sig { params(value: T.nilable(T.any(String, Symbol))).void }
  def contest_token=(value); end

  sig { returns(T::Boolean) }
  def contest_token?; end

  sig { returns(T.nilable(String)) }
  def contested_by_channel_id; end

  sig { params(value: T.nilable(T.any(String, Symbol))).void }
  def contested_by_channel_id=(value); end

  sig { returns(T::Boolean) }
  def contested_by_channel_id?; end

  sig { returns(ActiveSupport::TimeWithZone) }
  def created_at; end

  sig { params(value: T.any(Date, Time, ActiveSupport::TimeWithZone)).void }
  def created_at=(value); end

  sig { returns(T::Boolean) }
  def created_at?; end

  sig { returns(T::Boolean) }
  def created_via_api; end

  sig { params(value: T::Boolean).void }
  def created_via_api=(value); end

  sig { returns(T::Boolean) }
  def created_via_api?; end

  sig { returns(T.nilable(String)) }
  def deposit_id; end

  sig { params(value: T.nilable(T.any(String, Symbol))).void }
  def deposit_id=(value); end

  sig { returns(T::Boolean) }
  def deposit_id?; end

  sig { returns(T.nilable(String)) }
  def derived_brave_publisher_id; end

  sig { params(value: T.nilable(T.any(String, Symbol))).void }
  def derived_brave_publisher_id=(value); end

  sig { returns(T::Boolean) }
  def derived_brave_publisher_id?; end

  sig { returns(T.nilable(String)) }
  def details_id; end

  sig { params(value: T.nilable(T.any(String, Symbol))).void }
  def details_id=(value); end

  sig { returns(T::Boolean) }
  def details_id?; end

  sig { returns(T.nilable(String)) }
  def details_type; end

  sig { params(value: T.nilable(T.any(String, Symbol))).void }
  def details_type=(value); end

  sig { returns(T::Boolean) }
  def details_type?; end

  sig { returns(String) }
  def id; end

  sig { params(value: T.any(String, Symbol)).void }
  def id=(value); end

  sig { returns(T::Boolean) }
  def id?; end

  sig { returns(T.nilable(String)) }
  def publisher_id; end

  sig { params(value: T.nilable(T.any(String, Symbol))).void }
  def publisher_id=(value); end

  sig { returns(T::Boolean) }
  def publisher_id?; end

  sig { returns(ActiveSupport::TimeWithZone) }
  def updated_at; end

  sig { params(value: T.any(Date, Time, ActiveSupport::TimeWithZone)).void }
  def updated_at=(value); end

  sig { returns(T::Boolean) }
  def updated_at?; end

  sig { returns(T.nilable(String)) }
  def verification_details; end

  sig { params(value: T.nilable(T.any(String, Symbol))).void }
  def verification_details=(value); end

  sig { returns(T::Boolean) }
  def verification_details?; end

  sig { returns(T::Boolean) }
  def verification_pending; end

  sig { params(value: T::Boolean).void }
  def verification_pending=(value); end

  sig { returns(T::Boolean) }
  def verification_pending?; end

  sig { returns(T.nilable(String)) }
  def verification_status; end

  sig { params(value: T.nilable(T.any(String, Symbol))).void }
  def verification_status=(value); end

  sig { returns(T::Boolean) }
  def verification_status?; end

  sig { returns(T.nilable(T::Boolean)) }
  def verified; end

  sig { params(value: T.nilable(T::Boolean)).void }
  def verified=(value); end

  sig { returns(T::Boolean) }
  def verified?; end

  sig { returns(T.nilable(ActiveSupport::TimeWithZone)) }
  def verified_at; end

  sig { params(value: T.nilable(T.any(Date, Time, ActiveSupport::TimeWithZone))).void }
  def verified_at=(value); end

  sig { returns(T::Boolean) }
  def verified_at?; end
end

module Channel::GeneratedAssociationMethods
  sig { returns(T.nilable(::Channel)) }
  def contested_by_channel; end

  sig { params(args: T.untyped, block: T.nilable(T.proc.params(object: ::Channel).void)).returns(::Channel) }
  def build_contested_by_channel(*args, &block); end

  sig { params(args: T.untyped, block: T.nilable(T.proc.params(object: ::Channel).void)).returns(::Channel) }
  def create_contested_by_channel(*args, &block); end

  sig { params(args: T.untyped, block: T.nilable(T.proc.params(object: ::Channel).void)).returns(::Channel) }
  def create_contested_by_channel!(*args, &block); end

  sig { params(value: T.nilable(::Channel)).void }
  def contested_by_channel=(value); end

  sig { returns(T.nilable(::Channel)) }
  def reload_contested_by_channel; end

  sig { returns(T.nilable(::Channel)) }
  def contesting_channel; end

  sig { params(args: T.untyped, block: T.nilable(T.proc.params(object: ::Channel).void)).returns(::Channel) }
  def build_contesting_channel(*args, &block); end

  sig { params(args: T.untyped, block: T.nilable(T.proc.params(object: ::Channel).void)).returns(::Channel) }
  def create_contesting_channel(*args, &block); end

  sig { params(args: T.untyped, block: T.nilable(T.proc.params(object: ::Channel).void)).returns(::Channel) }
  def create_contesting_channel!(*args, &block); end

  sig { params(value: T.nilable(::Channel)).void }
  def contesting_channel=(value); end

  sig { returns(T.nilable(::Channel)) }
  def reload_contesting_channel; end

  sig { returns(T.untyped) }
  def details; end

  sig { params(args: T.untyped, block: T.nilable(T.proc.params(object: T.untyped).void)).returns(T.untyped) }
  def build_details(*args, &block); end

  sig { params(args: T.untyped, block: T.nilable(T.proc.params(object: T.untyped).void)).returns(T.untyped) }
  def create_details(*args, &block); end

  sig { params(args: T.untyped, block: T.nilable(T.proc.params(object: T.untyped).void)).returns(T.untyped) }
  def create_details!(*args, &block); end

  sig { params(value: T.untyped).void }
  def details=(value); end

  sig { returns(T.untyped) }
  def reload_details; end

  sig { returns(::GeminiConnectionForChannel::ActiveRecord_Associations_CollectionProxy) }
  def gemini_connection_for_channel; end

  sig { returns(T::Array[String]) }
  def gemini_connection_for_channel_ids; end

  sig { params(value: T::Enumerable[::GeminiConnectionForChannel]).void }
  def gemini_connection_for_channel=(value); end

  sig { returns(T.nilable(::GithubChannelDetails)) }
  def github_channel_details; end

  sig { params(args: T.untyped, block: T.nilable(T.proc.params(object: ::GithubChannelDetails).void)).returns(::GithubChannelDetails) }
  def build_github_channel_details(*args, &block); end

  sig { params(args: T.untyped, block: T.nilable(T.proc.params(object: ::GithubChannelDetails).void)).returns(::GithubChannelDetails) }
  def create_github_channel_details(*args, &block); end

  sig { params(args: T.untyped, block: T.nilable(T.proc.params(object: ::GithubChannelDetails).void)).returns(::GithubChannelDetails) }
  def create_github_channel_details!(*args, &block); end

  sig { params(value: T.nilable(::GithubChannelDetails)).void }
  def github_channel_details=(value); end

  sig { returns(T.nilable(::GithubChannelDetails)) }
  def reload_github_channel_details; end

  sig { returns(::PotentialPayment::ActiveRecord_Associations_CollectionProxy) }
  def potential_payments; end

  sig { returns(T::Array[String]) }
  def potential_payment_ids; end

  sig { params(value: T::Enumerable[::PotentialPayment]).void }
  def potential_payments=(value); end

  sig { returns(T.nilable(::PromoRegistration)) }
  def promo_registration; end

  sig { params(args: T.untyped, block: T.nilable(T.proc.params(object: ::PromoRegistration).void)).returns(::PromoRegistration) }
  def build_promo_registration(*args, &block); end

  sig { params(args: T.untyped, block: T.nilable(T.proc.params(object: ::PromoRegistration).void)).returns(::PromoRegistration) }
  def create_promo_registration(*args, &block); end

  sig { params(args: T.untyped, block: T.nilable(T.proc.params(object: ::PromoRegistration).void)).returns(::PromoRegistration) }
  def create_promo_registration!(*args, &block); end

  sig { params(value: T.nilable(::PromoRegistration)).void }
  def promo_registration=(value); end

  sig { returns(T.nilable(::PromoRegistration)) }
  def reload_promo_registration; end

  sig { returns(::Publisher) }
  def publisher; end

  sig { params(args: T.untyped, block: T.nilable(T.proc.params(object: ::Publisher).void)).returns(::Publisher) }
  def build_publisher(*args, &block); end

  sig { params(args: T.untyped, block: T.nilable(T.proc.params(object: ::Publisher).void)).returns(::Publisher) }
  def create_publisher(*args, &block); end

  sig { params(args: T.untyped, block: T.nilable(T.proc.params(object: ::Publisher).void)).returns(::Publisher) }
  def create_publisher!(*args, &block); end

  sig { params(value: ::Publisher).void }
  def publisher=(value); end

  sig { returns(::Publisher) }
  def reload_publisher; end

  sig { returns(T.nilable(::RedditChannelDetails)) }
  def reddit_channel_details; end

  sig { params(args: T.untyped, block: T.nilable(T.proc.params(object: ::RedditChannelDetails).void)).returns(::RedditChannelDetails) }
  def build_reddit_channel_details(*args, &block); end

  sig { params(args: T.untyped, block: T.nilable(T.proc.params(object: ::RedditChannelDetails).void)).returns(::RedditChannelDetails) }
  def create_reddit_channel_details(*args, &block); end

  sig { params(args: T.untyped, block: T.nilable(T.proc.params(object: ::RedditChannelDetails).void)).returns(::RedditChannelDetails) }
  def create_reddit_channel_details!(*args, &block); end

  sig { params(value: T.nilable(::RedditChannelDetails)).void }
  def reddit_channel_details=(value); end

  sig { returns(T.nilable(::RedditChannelDetails)) }
  def reload_reddit_channel_details; end

  sig { returns(T.nilable(::SiteBanner)) }
  def site_banner; end

  sig { params(args: T.untyped, block: T.nilable(T.proc.params(object: ::SiteBanner).void)).returns(::SiteBanner) }
  def build_site_banner(*args, &block); end

  sig { params(args: T.untyped, block: T.nilable(T.proc.params(object: ::SiteBanner).void)).returns(::SiteBanner) }
  def create_site_banner(*args, &block); end

  sig { params(args: T.untyped, block: T.nilable(T.proc.params(object: ::SiteBanner).void)).returns(::SiteBanner) }
  def create_site_banner!(*args, &block); end

  sig { params(value: T.nilable(::SiteBanner)).void }
  def site_banner=(value); end

  sig { returns(T.nilable(::SiteBanner)) }
  def reload_site_banner; end

  sig { returns(T.nilable(::SiteBannerLookup)) }
  def site_banner_lookup; end

  sig { params(args: T.untyped, block: T.nilable(T.proc.params(object: ::SiteBannerLookup).void)).returns(::SiteBannerLookup) }
  def build_site_banner_lookup(*args, &block); end

  sig { params(args: T.untyped, block: T.nilable(T.proc.params(object: ::SiteBannerLookup).void)).returns(::SiteBannerLookup) }
  def create_site_banner_lookup(*args, &block); end

  sig { params(args: T.untyped, block: T.nilable(T.proc.params(object: ::SiteBannerLookup).void)).returns(::SiteBannerLookup) }
  def create_site_banner_lookup!(*args, &block); end

  sig { params(value: T.nilable(::SiteBannerLookup)).void }
  def site_banner_lookup=(value); end

  sig { returns(T.nilable(::SiteBannerLookup)) }
  def reload_site_banner_lookup; end

  sig { returns(T.nilable(::SiteChannelDetails)) }
  def site_channel_details; end

  sig { params(args: T.untyped, block: T.nilable(T.proc.params(object: ::SiteChannelDetails).void)).returns(::SiteChannelDetails) }
  def build_site_channel_details(*args, &block); end

  sig { params(args: T.untyped, block: T.nilable(T.proc.params(object: ::SiteChannelDetails).void)).returns(::SiteChannelDetails) }
  def create_site_channel_details(*args, &block); end

  sig { params(args: T.untyped, block: T.nilable(T.proc.params(object: ::SiteChannelDetails).void)).returns(::SiteChannelDetails) }
  def create_site_channel_details!(*args, &block); end

  sig { params(value: T.nilable(::SiteChannelDetails)).void }
  def site_channel_details=(value); end

  sig { returns(T.nilable(::SiteChannelDetails)) }
  def reload_site_channel_details; end

  sig { returns(T.nilable(::TwitchChannelDetails)) }
  def twitch_channel_details; end

  sig { params(args: T.untyped, block: T.nilable(T.proc.params(object: ::TwitchChannelDetails).void)).returns(::TwitchChannelDetails) }
  def build_twitch_channel_details(*args, &block); end

  sig { params(args: T.untyped, block: T.nilable(T.proc.params(object: ::TwitchChannelDetails).void)).returns(::TwitchChannelDetails) }
  def create_twitch_channel_details(*args, &block); end

  sig { params(args: T.untyped, block: T.nilable(T.proc.params(object: ::TwitchChannelDetails).void)).returns(::TwitchChannelDetails) }
  def create_twitch_channel_details!(*args, &block); end

  sig { params(value: T.nilable(::TwitchChannelDetails)).void }
  def twitch_channel_details=(value); end

  sig { returns(T.nilable(::TwitchChannelDetails)) }
  def reload_twitch_channel_details; end

  sig { returns(T.nilable(::TwitterChannelDetails)) }
  def twitter_channel_details; end

  sig { params(args: T.untyped, block: T.nilable(T.proc.params(object: ::TwitterChannelDetails).void)).returns(::TwitterChannelDetails) }
  def build_twitter_channel_details(*args, &block); end

  sig { params(args: T.untyped, block: T.nilable(T.proc.params(object: ::TwitterChannelDetails).void)).returns(::TwitterChannelDetails) }
  def create_twitter_channel_details(*args, &block); end

  sig { params(args: T.untyped, block: T.nilable(T.proc.params(object: ::TwitterChannelDetails).void)).returns(::TwitterChannelDetails) }
  def create_twitter_channel_details!(*args, &block); end

  sig { params(value: T.nilable(::TwitterChannelDetails)).void }
  def twitter_channel_details=(value); end

  sig { returns(T.nilable(::TwitterChannelDetails)) }
  def reload_twitter_channel_details; end

  sig { returns(::UpholdConnectionForChannel::ActiveRecord_Associations_CollectionProxy) }
  def uphold_connection_for_channel; end

  sig { returns(T::Array[String]) }
  def uphold_connection_for_channel_ids; end

  sig { params(value: T::Enumerable[::UpholdConnectionForChannel]).void }
  def uphold_connection_for_channel=(value); end

  sig { returns(::PaperTrail::Version::ActiveRecord_Associations_CollectionProxy) }
  def versions; end

  sig { returns(T::Array[String]) }
  def version_ids; end

  sig { params(value: T::Enumerable[::PaperTrail::Version]).void }
  def versions=(value); end

  sig { returns(T.nilable(::VimeoChannelDetails)) }
  def vimeo_channel_details; end

  sig { params(args: T.untyped, block: T.nilable(T.proc.params(object: ::VimeoChannelDetails).void)).returns(::VimeoChannelDetails) }
  def build_vimeo_channel_details(*args, &block); end

  sig { params(args: T.untyped, block: T.nilable(T.proc.params(object: ::VimeoChannelDetails).void)).returns(::VimeoChannelDetails) }
  def create_vimeo_channel_details(*args, &block); end

  sig { params(args: T.untyped, block: T.nilable(T.proc.params(object: ::VimeoChannelDetails).void)).returns(::VimeoChannelDetails) }
  def create_vimeo_channel_details!(*args, &block); end

  sig { params(value: T.nilable(::VimeoChannelDetails)).void }
  def vimeo_channel_details=(value); end

  sig { returns(T.nilable(::VimeoChannelDetails)) }
  def reload_vimeo_channel_details; end

  sig { returns(T.nilable(::YoutubeChannelDetails)) }
  def youtube_channel_details; end

  sig { params(args: T.untyped, block: T.nilable(T.proc.params(object: ::YoutubeChannelDetails).void)).returns(::YoutubeChannelDetails) }
  def build_youtube_channel_details(*args, &block); end

  sig { params(args: T.untyped, block: T.nilable(T.proc.params(object: ::YoutubeChannelDetails).void)).returns(::YoutubeChannelDetails) }
  def create_youtube_channel_details(*args, &block); end

  sig { params(args: T.untyped, block: T.nilable(T.proc.params(object: ::YoutubeChannelDetails).void)).returns(::YoutubeChannelDetails) }
  def create_youtube_channel_details!(*args, &block); end

  sig { params(value: T.nilable(::YoutubeChannelDetails)).void }
  def youtube_channel_details=(value); end

  sig { returns(T.nilable(::YoutubeChannelDetails)) }
  def reload_youtube_channel_details; end
end

module Channel::CustomFinderMethods
  sig { params(limit: Integer).returns(T::Array[Channel]) }
  def first_n(limit); end

  sig { params(limit: Integer).returns(T::Array[Channel]) }
  def last_n(limit); end

  sig { params(args: T::Array[T.any(Integer, String)]).returns(T::Array[Channel]) }
  def find_n(*args); end

  sig { params(id: T.nilable(Integer)).returns(T.nilable(Channel)) }
  def find_by_id(id); end

  sig { params(id: Integer).returns(Channel) }
  def find_by_id!(id); end
end

class Channel < ApplicationRecord
  include Channel::GeneratedAttributeMethods
  include Channel::GeneratedAssociationMethods
  extend Channel::CustomFinderMethods
  extend Channel::QueryMethodsReturningRelation
  RelationType = T.type_alias { T.any(Channel::ActiveRecord_Relation, Channel::ActiveRecord_Associations_CollectionProxy, Channel::ActiveRecord_AssociationRelation) }

  sig { params(args: T.untyped).returns(Channel::ActiveRecord_Relation) }
  def self.contested_channels_ready_to_transfer(*args); end

  sig { params(args: T.untyped).returns(Channel::ActiveRecord_Relation) }
  def self.github_channels(*args); end

  sig { params(args: T.untyped).returns(Channel::ActiveRecord_Relation) }
  def self.not_visible_site_channels(*args); end

  sig { params(args: T.untyped).returns(Channel::ActiveRecord_Relation) }
  def self.other_verified_github_channels(*args); end

  sig { params(args: T.untyped).returns(Channel::ActiveRecord_Relation) }
  def self.other_verified_reddit_channels(*args); end

  sig { params(args: T.untyped).returns(Channel::ActiveRecord_Relation) }
  def self.other_verified_site_channels(*args); end

  sig { params(args: T.untyped).returns(Channel::ActiveRecord_Relation) }
  def self.other_verified_twitch_channels(*args); end

  sig { params(args: T.untyped).returns(Channel::ActiveRecord_Relation) }
  def self.other_verified_twitter_channels(*args); end

  sig { params(args: T.untyped).returns(Channel::ActiveRecord_Relation) }
  def self.other_verified_vimeo_channels(*args); end

  sig { params(args: T.untyped).returns(Channel::ActiveRecord_Relation) }
  def self.other_verified_youtube_channels(*args); end

  sig { params(args: T.untyped).returns(Channel::ActiveRecord_Relation) }
  def self.reddit_channels(*args); end

  sig { params(args: T.untyped).returns(Channel::ActiveRecord_Relation) }
  def self.site_channels(*args); end

  sig { params(args: T.untyped).returns(Channel::ActiveRecord_Relation) }
  def self.twitch_channels(*args); end

  sig { params(args: T.untyped).returns(Channel::ActiveRecord_Relation) }
  def self.twitter_channels(*args); end

  sig { params(args: T.untyped).returns(Channel::ActiveRecord_Relation) }
  def self.verified(*args); end

  sig { params(args: T.untyped).returns(Channel::ActiveRecord_Relation) }
  def self.vimeo_channels(*args); end

  sig { params(args: T.untyped).returns(Channel::ActiveRecord_Relation) }
  def self.visible(*args); end

  sig { params(args: T.untyped).returns(Channel::ActiveRecord_Relation) }
  def self.visible_github_channels(*args); end

  sig { params(args: T.untyped).returns(Channel::ActiveRecord_Relation) }
  def self.visible_reddit_channels(*args); end

  sig { params(args: T.untyped).returns(Channel::ActiveRecord_Relation) }
  def self.visible_site_channels(*args); end

  sig { params(args: T.untyped).returns(Channel::ActiveRecord_Relation) }
  def self.visible_twitch_channels(*args); end

  sig { params(args: T.untyped).returns(Channel::ActiveRecord_Relation) }
  def self.visible_twitter_channels(*args); end

  sig { params(args: T.untyped).returns(Channel::ActiveRecord_Relation) }
  def self.visible_vimeo_channels(*args); end

  sig { params(args: T.untyped).returns(Channel::ActiveRecord_Relation) }
  def self.visible_youtube_channels(*args); end

  sig { params(args: T.untyped).returns(Channel::ActiveRecord_Relation) }
  def self.youtube_channels(*args); end
end

class Channel::ActiveRecord_Relation < ActiveRecord::Relation
  include Channel::ActiveRelation_WhereNot
  include Channel::CustomFinderMethods
  include Channel::QueryMethodsReturningRelation
  Elem = type_member(fixed: Channel)

  sig { params(args: T.untyped).returns(Channel::ActiveRecord_Relation) }
  def contested_channels_ready_to_transfer(*args); end

  sig { params(args: T.untyped).returns(Channel::ActiveRecord_Relation) }
  def github_channels(*args); end

  sig { params(args: T.untyped).returns(Channel::ActiveRecord_Relation) }
  def not_visible_site_channels(*args); end

  sig { params(args: T.untyped).returns(Channel::ActiveRecord_Relation) }
  def other_verified_github_channels(*args); end

  sig { params(args: T.untyped).returns(Channel::ActiveRecord_Relation) }
  def other_verified_reddit_channels(*args); end

  sig { params(args: T.untyped).returns(Channel::ActiveRecord_Relation) }
  def other_verified_site_channels(*args); end

  sig { params(args: T.untyped).returns(Channel::ActiveRecord_Relation) }
  def other_verified_twitch_channels(*args); end

  sig { params(args: T.untyped).returns(Channel::ActiveRecord_Relation) }
  def other_verified_twitter_channels(*args); end

  sig { params(args: T.untyped).returns(Channel::ActiveRecord_Relation) }
  def other_verified_vimeo_channels(*args); end

  sig { params(args: T.untyped).returns(Channel::ActiveRecord_Relation) }
  def other_verified_youtube_channels(*args); end

  sig { params(args: T.untyped).returns(Channel::ActiveRecord_Relation) }
  def reddit_channels(*args); end

  sig { params(args: T.untyped).returns(Channel::ActiveRecord_Relation) }
  def site_channels(*args); end

  sig { params(args: T.untyped).returns(Channel::ActiveRecord_Relation) }
  def twitch_channels(*args); end

  sig { params(args: T.untyped).returns(Channel::ActiveRecord_Relation) }
  def twitter_channels(*args); end

  sig { params(args: T.untyped).returns(Channel::ActiveRecord_Relation) }
  def verified(*args); end

  sig { params(args: T.untyped).returns(Channel::ActiveRecord_Relation) }
  def vimeo_channels(*args); end

  sig { params(args: T.untyped).returns(Channel::ActiveRecord_Relation) }
  def visible(*args); end

  sig { params(args: T.untyped).returns(Channel::ActiveRecord_Relation) }
  def visible_github_channels(*args); end

  sig { params(args: T.untyped).returns(Channel::ActiveRecord_Relation) }
  def visible_reddit_channels(*args); end

  sig { params(args: T.untyped).returns(Channel::ActiveRecord_Relation) }
  def visible_site_channels(*args); end

  sig { params(args: T.untyped).returns(Channel::ActiveRecord_Relation) }
  def visible_twitch_channels(*args); end

  sig { params(args: T.untyped).returns(Channel::ActiveRecord_Relation) }
  def visible_twitter_channels(*args); end

  sig { params(args: T.untyped).returns(Channel::ActiveRecord_Relation) }
  def visible_vimeo_channels(*args); end

  sig { params(args: T.untyped).returns(Channel::ActiveRecord_Relation) }
  def visible_youtube_channels(*args); end

  sig { params(args: T.untyped).returns(Channel::ActiveRecord_Relation) }
  def youtube_channels(*args); end
end

class Channel::ActiveRecord_AssociationRelation < ActiveRecord::AssociationRelation
  include Channel::ActiveRelation_WhereNot
  include Channel::CustomFinderMethods
  include Channel::QueryMethodsReturningAssociationRelation
  Elem = type_member(fixed: Channel)

  sig { params(args: T.untyped).returns(Channel::ActiveRecord_AssociationRelation) }
  def contested_channels_ready_to_transfer(*args); end

  sig { params(args: T.untyped).returns(Channel::ActiveRecord_AssociationRelation) }
  def github_channels(*args); end

  sig { params(args: T.untyped).returns(Channel::ActiveRecord_AssociationRelation) }
  def not_visible_site_channels(*args); end

  sig { params(args: T.untyped).returns(Channel::ActiveRecord_AssociationRelation) }
  def other_verified_github_channels(*args); end

  sig { params(args: T.untyped).returns(Channel::ActiveRecord_AssociationRelation) }
  def other_verified_reddit_channels(*args); end

  sig { params(args: T.untyped).returns(Channel::ActiveRecord_AssociationRelation) }
  def other_verified_site_channels(*args); end

  sig { params(args: T.untyped).returns(Channel::ActiveRecord_AssociationRelation) }
  def other_verified_twitch_channels(*args); end

  sig { params(args: T.untyped).returns(Channel::ActiveRecord_AssociationRelation) }
  def other_verified_twitter_channels(*args); end

  sig { params(args: T.untyped).returns(Channel::ActiveRecord_AssociationRelation) }
  def other_verified_vimeo_channels(*args); end

  sig { params(args: T.untyped).returns(Channel::ActiveRecord_AssociationRelation) }
  def other_verified_youtube_channels(*args); end

  sig { params(args: T.untyped).returns(Channel::ActiveRecord_AssociationRelation) }
  def reddit_channels(*args); end

  sig { params(args: T.untyped).returns(Channel::ActiveRecord_AssociationRelation) }
  def site_channels(*args); end

  sig { params(args: T.untyped).returns(Channel::ActiveRecord_AssociationRelation) }
  def twitch_channels(*args); end

  sig { params(args: T.untyped).returns(Channel::ActiveRecord_AssociationRelation) }
  def twitter_channels(*args); end

  sig { params(args: T.untyped).returns(Channel::ActiveRecord_AssociationRelation) }
  def verified(*args); end

  sig { params(args: T.untyped).returns(Channel::ActiveRecord_AssociationRelation) }
  def vimeo_channels(*args); end

  sig { params(args: T.untyped).returns(Channel::ActiveRecord_AssociationRelation) }
  def visible(*args); end

  sig { params(args: T.untyped).returns(Channel::ActiveRecord_AssociationRelation) }
  def visible_github_channels(*args); end

  sig { params(args: T.untyped).returns(Channel::ActiveRecord_AssociationRelation) }
  def visible_reddit_channels(*args); end

  sig { params(args: T.untyped).returns(Channel::ActiveRecord_AssociationRelation) }
  def visible_site_channels(*args); end

  sig { params(args: T.untyped).returns(Channel::ActiveRecord_AssociationRelation) }
  def visible_twitch_channels(*args); end

  sig { params(args: T.untyped).returns(Channel::ActiveRecord_AssociationRelation) }
  def visible_twitter_channels(*args); end

  sig { params(args: T.untyped).returns(Channel::ActiveRecord_AssociationRelation) }
  def visible_vimeo_channels(*args); end

  sig { params(args: T.untyped).returns(Channel::ActiveRecord_AssociationRelation) }
  def visible_youtube_channels(*args); end

  sig { params(args: T.untyped).returns(Channel::ActiveRecord_AssociationRelation) }
  def youtube_channels(*args); end
end

class Channel::ActiveRecord_Associations_CollectionProxy < ActiveRecord::Associations::CollectionProxy
  include Channel::CustomFinderMethods
  include Channel::QueryMethodsReturningAssociationRelation
  Elem = type_member(fixed: Channel)

  sig { params(args: T.untyped).returns(Channel::ActiveRecord_AssociationRelation) }
  def contested_channels_ready_to_transfer(*args); end

  sig { params(args: T.untyped).returns(Channel::ActiveRecord_AssociationRelation) }
  def github_channels(*args); end

  sig { params(args: T.untyped).returns(Channel::ActiveRecord_AssociationRelation) }
  def not_visible_site_channels(*args); end

  sig { params(args: T.untyped).returns(Channel::ActiveRecord_AssociationRelation) }
  def other_verified_github_channels(*args); end

  sig { params(args: T.untyped).returns(Channel::ActiveRecord_AssociationRelation) }
  def other_verified_reddit_channels(*args); end

  sig { params(args: T.untyped).returns(Channel::ActiveRecord_AssociationRelation) }
  def other_verified_site_channels(*args); end

  sig { params(args: T.untyped).returns(Channel::ActiveRecord_AssociationRelation) }
  def other_verified_twitch_channels(*args); end

  sig { params(args: T.untyped).returns(Channel::ActiveRecord_AssociationRelation) }
  def other_verified_twitter_channels(*args); end

  sig { params(args: T.untyped).returns(Channel::ActiveRecord_AssociationRelation) }
  def other_verified_vimeo_channels(*args); end

  sig { params(args: T.untyped).returns(Channel::ActiveRecord_AssociationRelation) }
  def other_verified_youtube_channels(*args); end

  sig { params(args: T.untyped).returns(Channel::ActiveRecord_AssociationRelation) }
  def reddit_channels(*args); end

  sig { params(args: T.untyped).returns(Channel::ActiveRecord_AssociationRelation) }
  def site_channels(*args); end

  sig { params(args: T.untyped).returns(Channel::ActiveRecord_AssociationRelation) }
  def twitch_channels(*args); end

  sig { params(args: T.untyped).returns(Channel::ActiveRecord_AssociationRelation) }
  def twitter_channels(*args); end

  sig { params(args: T.untyped).returns(Channel::ActiveRecord_AssociationRelation) }
  def verified(*args); end

  sig { params(args: T.untyped).returns(Channel::ActiveRecord_AssociationRelation) }
  def vimeo_channels(*args); end

  sig { params(args: T.untyped).returns(Channel::ActiveRecord_AssociationRelation) }
  def visible(*args); end

  sig { params(args: T.untyped).returns(Channel::ActiveRecord_AssociationRelation) }
  def visible_github_channels(*args); end

  sig { params(args: T.untyped).returns(Channel::ActiveRecord_AssociationRelation) }
  def visible_reddit_channels(*args); end

  sig { params(args: T.untyped).returns(Channel::ActiveRecord_AssociationRelation) }
  def visible_site_channels(*args); end

  sig { params(args: T.untyped).returns(Channel::ActiveRecord_AssociationRelation) }
  def visible_twitch_channels(*args); end

  sig { params(args: T.untyped).returns(Channel::ActiveRecord_AssociationRelation) }
  def visible_twitter_channels(*args); end

  sig { params(args: T.untyped).returns(Channel::ActiveRecord_AssociationRelation) }
  def visible_vimeo_channels(*args); end

  sig { params(args: T.untyped).returns(Channel::ActiveRecord_AssociationRelation) }
  def visible_youtube_channels(*args); end

  sig { params(args: T.untyped).returns(Channel::ActiveRecord_AssociationRelation) }
  def youtube_channels(*args); end

  sig { params(records: T.any(Channel, T::Array[Channel])).returns(T.self_type) }
  def <<(*records); end

  sig { params(records: T.any(Channel, T::Array[Channel])).returns(T.self_type) }
  def append(*records); end

  sig { params(records: T.any(Channel, T::Array[Channel])).returns(T.self_type) }
  def push(*records); end

  sig { params(records: T.any(Channel, T::Array[Channel])).returns(T.self_type) }
  def concat(*records); end
end

module Channel::QueryMethodsReturningRelation
  sig { returns(Channel::ActiveRecord_Relation) }
  def all; end

  sig { params(block: T.nilable(T.proc.void)).returns(Channel::ActiveRecord_Relation) }
  def unscoped(&block); end

  sig { params(args: T.untyped).returns(Channel::ActiveRecord_Relation) }
  def select(*args); end

  sig { params(args: T.untyped).returns(Channel::ActiveRecord_Relation) }
  def reselect(*args); end

  sig { params(args: T.untyped).returns(Channel::ActiveRecord_Relation) }
  def order(*args); end

  sig { params(args: T.untyped).returns(Channel::ActiveRecord_Relation) }
  def reorder(*args); end

  sig { params(args: T.untyped).returns(Channel::ActiveRecord_Relation) }
  def group(*args); end

  sig { params(args: T.untyped).returns(Channel::ActiveRecord_Relation) }
  def limit(*args); end

  sig { params(args: T.untyped).returns(Channel::ActiveRecord_Relation) }
  def offset(*args); end

  sig { params(args: T.untyped).returns(Channel::ActiveRecord_Relation) }
  def joins(*args); end

  sig { params(args: T.untyped).returns(Channel::ActiveRecord_Relation) }
  def left_joins(*args); end

  sig { params(args: T.untyped).returns(Channel::ActiveRecord_Relation) }
  def left_outer_joins(*args); end

  sig { params(args: T.untyped).returns(Channel::ActiveRecord_Relation) }
  def where(*args); end

  sig { params(args: T.untyped).returns(Channel::ActiveRecord_Relation) }
  def rewhere(*args); end

  sig { params(args: T.untyped).returns(Channel::ActiveRecord_Relation) }
  def preload(*args); end

  sig { params(args: T.untyped).returns(Channel::ActiveRecord_Relation) }
  def extract_associated(*args); end

  sig { params(args: T.untyped).returns(Channel::ActiveRecord_Relation) }
  def eager_load(*args); end

  sig { params(args: T.untyped).returns(Channel::ActiveRecord_Relation) }
  def includes(*args); end

  sig { params(args: T.untyped).returns(Channel::ActiveRecord_Relation) }
  def from(*args); end

  sig { params(args: T.untyped).returns(Channel::ActiveRecord_Relation) }
  def lock(*args); end

  sig { params(args: T.untyped).returns(Channel::ActiveRecord_Relation) }
  def readonly(*args); end

  sig { params(args: T.untyped).returns(Channel::ActiveRecord_Relation) }
  def or(*args); end

  sig { params(args: T.untyped).returns(Channel::ActiveRecord_Relation) }
  def having(*args); end

  sig { params(args: T.untyped).returns(Channel::ActiveRecord_Relation) }
  def create_with(*args); end

  sig { params(args: T.untyped).returns(Channel::ActiveRecord_Relation) }
  def distinct(*args); end

  sig { params(args: T.untyped).returns(Channel::ActiveRecord_Relation) }
  def references(*args); end

  sig { params(args: T.untyped).returns(Channel::ActiveRecord_Relation) }
  def none(*args); end

  sig { params(args: T.untyped).returns(Channel::ActiveRecord_Relation) }
  def unscope(*args); end

  sig { params(args: T.untyped).returns(Channel::ActiveRecord_Relation) }
  def optimizer_hints(*args); end

  sig { params(args: T.untyped).returns(Channel::ActiveRecord_Relation) }
  def merge(*args); end

  sig { params(args: T.untyped).returns(Channel::ActiveRecord_Relation) }
  def except(*args); end

  sig { params(args: T.untyped).returns(Channel::ActiveRecord_Relation) }
  def only(*args); end

  sig { params(args: T.untyped, block: T.nilable(T.proc.void)).returns(Channel::ActiveRecord_Relation) }
  def extending(*args, &block); end

  sig do
    params(
      of: T.nilable(Integer),
      start: T.nilable(Integer),
      finish: T.nilable(Integer),
      load: T.nilable(T::Boolean),
      error_on_ignore: T.nilable(T::Boolean),
      block: T.nilable(T.proc.params(e: Channel::ActiveRecord_Relation).void)
    ).returns(ActiveRecord::Batches::BatchEnumerator)
  end
  def in_batches(of: 1000, start: nil, finish: nil, load: false, error_on_ignore: nil, &block); end
end

module Channel::QueryMethodsReturningAssociationRelation
  sig { returns(Channel::ActiveRecord_AssociationRelation) }
  def all; end

  sig { params(block: T.nilable(T.proc.void)).returns(Channel::ActiveRecord_Relation) }
  def unscoped(&block); end

  sig { params(args: T.untyped).returns(Channel::ActiveRecord_AssociationRelation) }
  def select(*args); end

  sig { params(args: T.untyped).returns(Channel::ActiveRecord_AssociationRelation) }
  def reselect(*args); end

  sig { params(args: T.untyped).returns(Channel::ActiveRecord_AssociationRelation) }
  def order(*args); end

  sig { params(args: T.untyped).returns(Channel::ActiveRecord_AssociationRelation) }
  def reorder(*args); end

  sig { params(args: T.untyped).returns(Channel::ActiveRecord_AssociationRelation) }
  def group(*args); end

  sig { params(args: T.untyped).returns(Channel::ActiveRecord_AssociationRelation) }
  def limit(*args); end

  sig { params(args: T.untyped).returns(Channel::ActiveRecord_AssociationRelation) }
  def offset(*args); end

  sig { params(args: T.untyped).returns(Channel::ActiveRecord_AssociationRelation) }
  def joins(*args); end

  sig { params(args: T.untyped).returns(Channel::ActiveRecord_AssociationRelation) }
  def left_joins(*args); end

  sig { params(args: T.untyped).returns(Channel::ActiveRecord_AssociationRelation) }
  def left_outer_joins(*args); end

  sig { params(args: T.untyped).returns(Channel::ActiveRecord_AssociationRelation) }
  def where(*args); end

  sig { params(args: T.untyped).returns(Channel::ActiveRecord_AssociationRelation) }
  def rewhere(*args); end

  sig { params(args: T.untyped).returns(Channel::ActiveRecord_AssociationRelation) }
  def preload(*args); end

  sig { params(args: T.untyped).returns(Channel::ActiveRecord_AssociationRelation) }
  def extract_associated(*args); end

  sig { params(args: T.untyped).returns(Channel::ActiveRecord_AssociationRelation) }
  def eager_load(*args); end

  sig { params(args: T.untyped).returns(Channel::ActiveRecord_AssociationRelation) }
  def includes(*args); end

  sig { params(args: T.untyped).returns(Channel::ActiveRecord_AssociationRelation) }
  def from(*args); end

  sig { params(args: T.untyped).returns(Channel::ActiveRecord_AssociationRelation) }
  def lock(*args); end

  sig { params(args: T.untyped).returns(Channel::ActiveRecord_AssociationRelation) }
  def readonly(*args); end

  sig { params(args: T.untyped).returns(Channel::ActiveRecord_AssociationRelation) }
  def or(*args); end

  sig { params(args: T.untyped).returns(Channel::ActiveRecord_AssociationRelation) }
  def having(*args); end

  sig { params(args: T.untyped).returns(Channel::ActiveRecord_AssociationRelation) }
  def create_with(*args); end

  sig { params(args: T.untyped).returns(Channel::ActiveRecord_AssociationRelation) }
  def distinct(*args); end

  sig { params(args: T.untyped).returns(Channel::ActiveRecord_AssociationRelation) }
  def references(*args); end

  sig { params(args: T.untyped).returns(Channel::ActiveRecord_AssociationRelation) }
  def none(*args); end

  sig { params(args: T.untyped).returns(Channel::ActiveRecord_AssociationRelation) }
  def unscope(*args); end

  sig { params(args: T.untyped).returns(Channel::ActiveRecord_AssociationRelation) }
  def optimizer_hints(*args); end

  sig { params(args: T.untyped).returns(Channel::ActiveRecord_AssociationRelation) }
  def merge(*args); end

  sig { params(args: T.untyped).returns(Channel::ActiveRecord_AssociationRelation) }
  def except(*args); end

  sig { params(args: T.untyped).returns(Channel::ActiveRecord_AssociationRelation) }
  def only(*args); end

  sig { params(args: T.untyped, block: T.nilable(T.proc.void)).returns(Channel::ActiveRecord_AssociationRelation) }
  def extending(*args, &block); end

  sig do
    params(
      of: T.nilable(Integer),
      start: T.nilable(Integer),
      finish: T.nilable(Integer),
      load: T.nilable(T::Boolean),
      error_on_ignore: T.nilable(T::Boolean),
      block: T.nilable(T.proc.params(e: Channel::ActiveRecord_AssociationRelation).void)
    ).returns(ActiveRecord::Batches::BatchEnumerator)
  end
  def in_batches(of: 1000, start: nil, finish: nil, load: false, error_on_ignore: nil, &block); end
end
