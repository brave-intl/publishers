class ReferralDownload < ApplicationRecord
  connects_to database: { writing: :stats_redshift, reading: :stats_redshift }
end
