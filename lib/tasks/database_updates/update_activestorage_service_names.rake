namespace :database_updates do
  desc 'Update ActiveStorage::Blob service_name after renaming from amazon to split buckets'
  task :update_activestorage_service_names => :environment do
    ActiveStorage::Blob.joins(:attachments).
      where(service_name: 'amazon').
      where("active_storage_attachments.record_type = 'SiteBanner'").
      update_all(service_name: 'amazon_public_bucket')

    # For Case, CaseNote, InvoiceFile
    ActiveStorage::Blob.
      joins(:attachments).
      where(service_name: 'amazon').
      where.not("active_storage_attachments.record_type = 'SiteBanner'").
      update_all(service_name: 'amazon_internal_bucket')
  end
end
