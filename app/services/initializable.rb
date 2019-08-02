module Initializable
  def initialize(params = {})
    # So this is a ruby meta-programming method, basically anytime that you call initialize with a series of params like so
    # Object.new(id: "1234", some_property: "foobar")
    # Then for each of those params we'll iterate those and call the associated setter method. In this example this method would call the methods id=, and some_property=.
    # Now, this is where it kind of gets strange because you'll notice in user.rb and card.rb I do not define any methods like this.
    # That's where attr_accessor comes in. This method allows for a shorthand for generating getters/setters.
    params.each do |key, value|
      setter = "#{key}="
      send(setter, value) if respond_to?(setter.to_sym, false)
    end
  end
end
