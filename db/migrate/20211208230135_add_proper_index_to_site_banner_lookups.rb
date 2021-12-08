class AddProperIndexToSiteBannerLookups < ActiveRecord::Migration[6.1]
  def change
    execute %Q{
      CREATE INDEX IF NOT EXISTS index_site_banner_lookups_collation_c_on_sha_base16
      ON site_banner_lookups USING btree
      (sha2_base16 COLLATE pg_catalog."C" text_pattern_ops ASC NULLS LAST);
    }
  end
end
