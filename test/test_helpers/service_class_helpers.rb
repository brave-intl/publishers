# typed: false
module ServiceClassHelpers
  def success_struct_empty
    BSuccess.new(result: true)
  end

  def error_struct
    BFailure.new(errors: [StandardError.new("error")])
  end
end
