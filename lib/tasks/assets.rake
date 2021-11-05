Rake::Task["assets:precompile"].enhance do
  Rake::Task["assets:postcompile"].execute
end

namespace :assets do
  task postcompile: :environment do
    puts "Running postcompile"

    # To maintain parity between the different deployments
    # We're going to replace the assets digest with the SHA of the Git commit
    webpack_manifest = Rails.root.join("public", "packs", "manifest.json")
    sprockets_manifest = Dir[Rails.root.join("public", "assets", ".*.json")].first

    sha = ENV["SOURCE_VERSION"] || `git rev-parse HEAD`.strip
    WebpackManifest.new(file: webpack_manifest, sha: sha).execute!
    SprocketsManifest.new(file: sprockets_manifest, sha: sha).execute!

    puts "Postcompile complete"
  end
end

class Manifest
  attr_reader :data, :sha, :file, :directory

  DIGEST_REGEX = /-[A-Fa-f0-9]{8}.*\./.freeze

  def initialize(file:, sha:)
    @file = file
    @directory = File.dirname(file).sub("/packs", "")
    @data = JSON.parse(File.read(file))
    @sha = sha
  end

  def manifest_entry
    proc do |value|
      new_value = value
      if DIGEST_REGEX.match?(value)
        new_value = new_value.gsub(DIGEST_REGEX, "-#{sha}.")
        FileUtils.copy("#{directory}/#{value}", "#{directory}/#{new_value}")
      end

      new_value
    end
  end
end

class WebpackManifest < Manifest
  def execute!
    data = self.data.deep_transform_values(&manifest_entry)
    File.write(file, JSON.pretty_generate(data))
  end
end

class SprocketsManifest < Manifest
  def execute!
    data["assets"] = data["assets"].deep_transform_values(&manifest_entry)
    File.write(file, JSON.pretty_generate(data))
  end
end
