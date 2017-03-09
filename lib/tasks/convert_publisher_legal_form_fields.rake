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
task :download_legal_form_fields_json, [:json_path] => [:environment] do |_t, args|
  FILE_DIR = "./decode_legal_form_fields_json".freeze
  FileUtils.mkdir_p(FILE_DIR)
  if args[:json_path].blank?
    raise "1 arg is required, JSON of LegalForm ids and S3 URLs to download."
  end
  ids_urls = JSON.parse(File.read(args[:json_path]))
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

desc "Take mapping of {document field count}: [{field names}], and .json files in decode_legal_form_fields_json and replace JSONs's field names with the mapping."
task :convert_publisher_legal_form_fields, [:mapping] => [:environment] do |_t, args|
  DEFAULT_MAPPING = {
    # W-9
    16 => %w(tinType taxClassification signature dateSigned name cityStateZip address businessName exemptPayeeCode fatcaExemption requesterNameAddress accountNumbers taxClassificationLlc taxClassificationOther ein ssn),
    # W-8BEN
    24 => %w(signature dateSigned name citizenshipCountry residenceAddress residenceCityState residenceCountry residencePlace dateOfBirth foreignTin signerName mailingCityState mailingCountry mailingAddress usTin referenceNumbers specialRateArticle specialRate specialRateIncomeType1 specialRateIncomeType2 specialRateReasons2 specialRateReasons3 specialRateReasons1 signerCapacity),
    # W-8BEN-E
    134 => %w(fatcaStatusParticipatingFFI fatcaStatusReportingModel2Ffi fatcaStatusLimitedBranch fatcaStatusUsBranch fatcaStatusReportingModel1Ffi taxTreatyIsResident taxTreatyBenefitDerived taxTreatyBenefitDerivedTaxExemptPension taxTreatyBenefitDerivedOtherTaxExempt taxTreatyBenefitDerivedPublicCorporation taxTreatyBenefitDerivedGovernment taxTreatyBenefitDerivedSubsidiaryPublicCorporation taxTreatyBenefitDerivedCompanyDerivativeBenefitsTest taxTreatyBenefitDerivedCompanyOwnershipErosion taxTreatyBenefitDerivedCompanyActiveTradeTest taxTreatyBenefitDerivedUsAuthorityDiscretion taxTreatyQualifiedUsDividendsFromForeign sponsoredFfiCertification1 sponsoredFfiCertification2 partViCertification partVCertification partViiiCertification partIxCertification partXCertification2 partViiCertification partXCertification3 partXCertification4 partXiCertification1 partXiCertification2 partXCertification1 partXiCertification3 partXiiCertification partXiiModel1Iga partXiiModel2Iga partXivCertification1 partXivCertification2 partXvCertification1 partXvCertification2 partXiiiCertification partXvCertification3 partXvCertification4 partXvCertification5 partXvCertification6 partXviCertification1 partXviiiCertification1 partXixCertification1 partXxCertification1 partXviiCertification1 partXxiiCertification1 partXxiiiCertification1 partXxiCertification1 partXxiiiCertification2 partXxivCertification1 partXxvCertification1 partXxviCertification2 partXxviCertification3 partXxviiCertification1 partXxviCertification1 partXxviiiCertification1 taxTreatyBenefitDerivedOther entityType patcaStatus certification isHybridEntityMakingTreatyClaim signature dateSigned disregardedEntity organization country mailingAddress residenceAddress mailingAddressCityState mailingAddressCountry residenceCityState residenceCountry usTin giin referenceNumbers foreignTin signerName topmostSubform[0].Page2[0].f2_05[0] disregardedEntityAddress disregardedEntityCityState disregardedEntityCountry disregardedEntityGiin taxTreatyArticleParagraph taxTreatyWithholdingIncomeType taxTreatyAdditional1 taxTreatyWithholdingRate taxTreatyAdditional3 sponsoredFfiEntityName taxTreatyAdditional2 sponsoredFfiEntityGiin partViiEntityName partXiiEntity partXiiTrusteeSponsor partXiiTrusteeSponsorGiin partXiiTreatedAs partXixDate partXxDate partXxiDate partXxiiiTradedEntity partXxiiiStockMarkets partXxiiiSecuritiesMarket partXxviiEntityName partXxviiEntityGiin partXxixName1 partXxixName2 partXxixName3 partXxixName4 partXxixName5 partXxixName6 partXxixName8 partXxixName9 partXxixName7 partXxixAddress1 partXxixAddress2 partXxixAddress3 partXxixAddress4 partXxixAddress5 partXxixAddress6 partXxixAddress7 partXxixAddress8 partXxixAddress9 partXxixTin1 partXxixTin2 partXxixTin3 partXxixTin4 partXxixTin5 partXxixTin6 partXxixTin7 partXxixTin8 partXxixTin9 taxTreatyBenefitDerivedOtherText)
  }
  mappings = args[:mapping].present? ? JSON.parse(args[:mapping]) : DEFAULT_MAPPING

  PublisherLegalForm.find_each do |form|
    # Modified from PublisherLegalFormSyncer
    begin
      getter = DocusignEnvelopeRecipientsGetter.new(
        last_gotten_at: form.docusign_envelope_gotten_at,
        envelope_id: form.docusign_envelope_id
      )
      result = getter.perform
      signer = result["signers"][0]
      form.status = signer["status"]
      form.docusign_envelope_gotten_at = Time.zone.now

      fields = DocusignEnvelopeFieldsGetter.new(signer: signer).perform

      # This is the difference
      mapping = mappings[fields.keys.size]
      i = 0
      new_keys_values = fields.map do |_k, v|
        new_item = [mapping[i], v]
        i += 1
        new_item
      end
      i += 1
      fields = Hash[new_keys_values]

      data = JSON.pretty_generate(fields)
      EncryptedS3Store.new.put_object(data: data, key: form.form_fields_s3_key)
      form.save!
      puts "#{form.id} -- ok"
    rescue => e
      puts "#{form.id} -- #{e}"
    end
    sleep(1)
  end
end
