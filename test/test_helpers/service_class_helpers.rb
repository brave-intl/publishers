# typed: false

require "#{Rails.root}/app/services/builder_base_service"
module ServiceClassHelpers
  def success_struct_empty
    ::BSuccess.new(result: true)
  end

  def error_struct
    ::BFailure.new(errors: ["error"])
  end
end
