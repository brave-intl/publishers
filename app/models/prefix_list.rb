class PrefixList < ActiveRecord::Base
  include PublicS3
  has_one_public_s3 :prefix_list

  ALL_CHANNELS = "all_channels".freeze
end
