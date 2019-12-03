class PropertyGenerator < Rails::Generators::NamedBase
  include Rails::Generators::Migration

  source_root File.expand_path('templates', __dir__)

  def create_migration_file
    migration_template "create_table_migration.rb.erb", File.join("db/migrate", "create_#{table_name}.rb")
  end

  def create_model_file
    template "model.rb.erb", File.join("app/models", class_path, "#{file_name}.rb")
  end

  # Apparently have to implement this for migration_template
  def self.next_migration_number(path)
    next_migration_number = current_migration_number(path) + 1
    ActiveRecord::Migration.next_migration_number(next_migration_number)
  end
end
