require "fileutils"

desc "Generate JsonSchema Revision"
task :generate_json_schema, [:version] => [:environment] do |task, args|
  default_version = "v0"
  version = args.version || default_version

  schema_path = "schema/#{version}"

  if version != default_version && File.exist?(schema_path)
    raise "Could not create new revision '#{version}', because '#{version}' has already been published"
  else
    FileUtils.mkdir_p(schema_path)
  end

  definitions = [
    {model: Publisher, name: "User"},
    {model: UpholdConnection, name: "UpholdCustodian"},
    {model: GeminiConnection, name: "GeminiCustodian"},
    {model: BitflyerConnection, name: "BitflyerCustodian"}
  ]

  definitions.each do |obj|
    json_schema = JSON.pretty_generate(ApplicationRecordToJsonSchemaService.new.call(obj[:model], (obj[:name]).to_s, version))

    print(json_schema)

    File.open("public/schema/#{version}/#{obj[:name].downcase}.json", "w") do |f|
      f.write(json_schema)
      f.close
    end
  end
end
