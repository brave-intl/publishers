class BuilderBaseService
  def self.build
    new
  end

  def self.call(*args, **kwargs)
    inst = build
    result = nil
    errors = []

    # Establish basic interface
    unless inst.respond_to?(:call)
      raise NotImplementedError.new("Contract violation, Builder Service Children must implement call")
    end

    # Error handling by default
    begin
      result = inst.call(*args, **kwargs)
    rescue => e
      errors.append(e)
    end

    OpenStruct.new(success?: errors.empty?, errors: errors, result: result)
  end
end
