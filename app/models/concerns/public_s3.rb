require 'active_storage'

module PublicS3
  extend ActiveSupport::Concern

  included do
    def public_s3_service
      @service ||=
        case Rails.application.config.active_storage.public_service
        when :amazon
          Publishers::Service::PublicS3Service.new
        when :local
          ActiveStorage::Service::DiskService.new(root: Rails.root.join("storage"))
        else # Staging does not have an environment file
          Publishers::Service::PublicS3Service.new
        end
    end

    # This specifies the relation between a single attachment and the model
    #
    #   class User < ActiveRecord::Base
    #     has_one_public_s3 :avatar
    #   end
    #
    # Developers then may call on the object
    #
    #   User.upload_public_avatar(
    #     {
    #       io: read('image_path'),
    #       filename: 'image_name',
    #       content_type: "image/jpg"
    #     }
    #   )
    #
    # They may then retrieve the uploaded property by specifying
    #
    #    User.public_avatar_url
    #
    # This code has primarily been inspired by the original attachment API in Active Storage
    # Before making any modifications it is highly recommended that you review the original implementation
    # https://github.com/rails/rails/blob/v5.2.1.1/activestorage/lib/active_storage/attached/macros.rb#L30
    #
    # Two additional methods are introduced to encourage the developer to be explicit
    # when uploading/downloading files to and from public S3.
    #
    # If the user deletes the attachment it will schedule and ActiveJob to purge those requests
    def self.has_one_public_s3(name, dependent: :purge_later)
      class_eval <<-CODE, __FILE__, __LINE__ + 1
        def #{name}
          @active_storage_attached_#{name} ||= ActiveStorage::Attached::One.new("#{name}", self, dependent: #{dependent == :purge_later ? ":purge_later" : "false"})
        end

        def #{name}=(attachable)
          #{name}.attach(attachable)
        end

        # Influenced from build_after_upload in the ActiveStorage::Blob source code
        # https://github.com/rails/rails/blob/v5.2.1.1/activestorage/app/models/active_storage/blob.rb#L47
        #
        # When building a blob we must ensure the correct S3 service is being specified so that the backing code
        # uploads to the correct bucket. Otherwise it will use the default configured in the config/storage.yml
        def upload_public_#{name}(file)
          blob = ActiveStorage::Blob.new.tap do |blob|
            Rails.logger.info("ActiveStorage::Blob.new.tap c'mon")
            Rails.logger.info(blob)
            blob.filename     = file[:filename]
            blob.content_type = file[:content_type]
            # This ensures that the blob is uploaded to the correct S3 service
            blob.service = public_s3_service
            # Prevents the AnalyzeJob from running
            blob.metadata = { analyzed: true }

            Rails.logger.info("Attempting to upload file, next line has blob")
            Rails.logger.info(blob)
            blob.upload file[:io]
          end
          blob.save

          transaction do
            if self.public_send("#{name}_attachment").present?
              self.public_send("#{name}_attachment").destroy
              self.public_send("#{name}_attachment=", nil)
            end
            attachment = ActiveStorage::Attachment.new(record: self, name: "#{name}", blob: blob)
            self.public_send("#{name}_attachment=", attachment)
          end
        end

        def public_#{name}_url
          return if #{name}.attachment.blank?

          # ActiveStorage::Current.host = Rails.application.secrets[:s3_rewards_public_domain]
          if Rails.application.config.active_storage.public_service == :local
            ActiveStorage::Current.host = 'https://localhost:3000'
            filename = ActiveStorage::Filename.wrap(#{name}.blob.filename)

            # Supports both DiskService and the PublicS3 Service
            public_s3_service.url(
              #{name}.blob.key,
              expires_in: public_s3_service.url_expires_in,
              filename: filename,
              content_type: #{name}.blob.content_type,
              disposition: #{name}.blob.send(:forcibly_serve_as_binary?) ? :attachment : :inline
            )
          else
            url = Rails.application.secrets[:s3_rewards_public_domain]
            url += "/" + #{name}.blob.key
          end
        end

        def #{name}_purge_later
          PublicPurgeJob.perform_later(object: self, name: "#{name}")
        end

        # Deletes from the public_s3_service immediately
        def #{name}_detach
          return unless #{name}_attachment.present?

          # Destroy the attachment
          #{name}_attachment.destroy
          public_send("#{name}_attachment=", nil)

          # Delete from public s3
          key = #{name}.blob.key
          public_s3_service.delete(key)
          public_s3_service.delete_prefixed("variants/" + key + "/") if image?

          # Destroy the blob
          #{name}.blob.destroy
        end
      CODE

      has_one :"#{name}_attachment", -> { where(name: name) }, class_name: "ActiveStorage::Attachment", as: :record, inverse_of: :record, dependent: false
      has_one :"#{name}_blob", through: :"#{name}_attachment", class_name: "ActiveStorage::Blob", source: :blob

      scope :"with_attached_#{name}", -> { includes("#{name}_attachment": :blob) }

      if dependent == :purge_later
        after_destroy_commit { public_send("#{name}_purge_later") }
      else
        before_destroy { public_send("#{name}_detach") }
      end
    end
  end
end
