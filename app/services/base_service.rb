class BaseService
  def self.instance
    @__instance__ ||= new
  end
end
