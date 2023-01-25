# typed: true

class BuilderBaseService
  def self.build
  end

  def call(args)
  end

  def pass(val = true)
    BSuccess.new(result: val)
  end

  def problem(e)
    case e
    when String
      BFailure.new(errors: [e])
    when Array
      BFailure.new(errors: e)
    else
      raise e
    end
  end

  def shrug(result)
    case result
    when String
      BIndeterminate.new(result: [result])
    when Array
      BIndeterminate.new(result: result)
    else
      raise result
    end
  end
end
