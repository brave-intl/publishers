namespace :publishers do
  desc "Export eyeshade transition file"
  task :export_eyeshade_transition_data => [:environment] do
    file = File.open(File.expand_path("~/publishers_eyeshade_transition_file.json"), 'w')
    owners = Publisher.where.not(email: nil).order(:created_at)
    serializable_resource = ActiveModelSerializers::SerializableResource.new(owners)
    file.write serializable_resource.to_json
    file.close
  end
end