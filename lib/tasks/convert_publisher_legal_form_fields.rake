desc "For PublisherLegalForms created before 2017-02-23, fetch fields and convert to new semantic field format and save to S3."
task :get_publisher_legal_form_fields => [:environment] do
  PublisherLegalForm.find_each do |form|
    if form.form_fields_s3_key.present?
      puts "#{form.id} -- #form_fields_s3_key exists"
      next
    end
    begin
      PublisherLegalFormSyncer.new(publisher_legal_form: form).perform
      puts "#{form.id} -- ok"
    rescue => e
      puts "#{form.id} -- #{e}"
    end
    sleep(1)
  end
end

desc "For PublisherLegalForms prepare signed S3 URLs of #form_fields_s3_key objects as JSON."
task :get_publisher_legal_form_fields_s3_urls => [:environment] do
  result = {}
  PublisherLegalForm.find_each do |form|
    next if form.form_fields_s3_key.blank?
    s3_getter = PublisherLegalFormS3Getter.new(publisher_legal_form: form)
    result[form.id] = s3_getter.get_form_fields_s3_url
  end
  puts JSON.generate(result)
end

desc "Take JSON output of get_publisher_legal_form_fields_s3_urls and download files. To be run locally."
task :download_legal_form_fields_json, [:json] => [:environment] do |t, args|
  FILE_DIR = "./decode_legal_form_fields_json".freeze
  FileUtils.mkdir_p(FILE_DIR)
  if args[:json].blank?
    raise "1 arg is required, JSON of LegalForm ids and S3 URLs to download."
  end
  ids_urls = JSON.parse(args[:json])
  require "faraday"
  connection = Faraday.new do |faraday|
    faraday.adapter(Faraday.default_adapter)
    faraday.use(Faraday::Response::RaiseError)
  end
  ids_urls.each do |id, url|
    file_path = "#{FILE_DIR}/#{id}.json.gpg"
    puts(file_path)
    response = connection.get(url)
    File.open(file_path, "wb") do |f|
      f.write(response.body)
    end
  end
end
