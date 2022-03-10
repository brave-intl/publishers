require "docker/eyeshade_helper"
require "pg"

namespace :eyeshade do
  desc "Create Site Channel Balances"
  task :create_site_channel_balances, [:type] => [:environment] do |task, args|
    Docker::EyeshadeHelper.build.create_site_channel_balances
  end

  desc "Create Twitch Channel Balances"
  task :create_site_channel_balances, [:type] => [:environment] do |task, args|
    Docker::EyeshadeHelper.build.create_twitch_channel_balances
  end

  desc "Create Twitter Channel Balances"
  task :create_site_channel_balances, [:type] => [:environment] do |task, args|
    Docker::EyeshadeHelper.build.create_twitter_channel_balances
  end

  desc "Create Youtube Channel Balances"
  task :create_site_channel_balances, [:type] => [:environment] do |task, args|
    Docker::EyeshadeHelper.build.create_youtube_channel_balances
  end

  desc "Create All Channel Balances"
  task :create_channel_balances, [:type] => [:environment] do |task, args|
    Docker::EyeshadeHelper.build.create_channel_balances
  end
end
