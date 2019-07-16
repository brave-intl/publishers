module Initializable
  def initialize(params = {})
    params.each do |key, value|
      setter = "#{key}="
      send(setter, value) if respond_to?(setter.to_sym, false)
    end
  end
end
