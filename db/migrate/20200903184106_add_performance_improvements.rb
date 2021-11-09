# typed: ignore
class AddPerformanceImprovements < ActiveRecord::Migration[6.0]
  def change
    # Adding a gin index based off it's performance for text searches.
    # https://www.cybertec-postgresql.com/en/postgresql-more-performance-for-like-and-ilike-statements/
    enable_extension "btree_gin"
    add_index :site_banner_lookups, :sha2_base16, using: :gin, name: 'index_gin_site_banner_lookups_on_sha2_base16'

  end
end
