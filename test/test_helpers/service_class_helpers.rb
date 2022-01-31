# typed: false
module ServiceClassHelpers
  def success_struct_empty
    OpenStruct.new(success?: true, result: nil, errors: nil)
  end

  def error_struct
    OpenStruct.new(success?: false, result: nil, errors: [StandardError.new("error")])
  end
end
