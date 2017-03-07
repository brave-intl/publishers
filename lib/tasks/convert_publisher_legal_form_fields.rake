desc "For PublisherLegalForms created before 2017-02-23, fetch fields and convert to new semantic field format and save to S3."
task :convert_publisher_legal_form_fields, [:id] => [:environment] do
  # TODO
end

task :get_publisher_legal_form_fields => [:environment] do
  PublisherLegalForm.find_each do |form|
    if form.form_fields_s3_key.present?
      puts "#{form.id} -- #form_fields_s3_key exists"
      next
    end
    PublisherLegalFormSyncer.new(publisher_legal_form: form).perform
    sleep(1)
  end
end
