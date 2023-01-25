# typed: true

class RedisCountService < BuilderBaseService
  BelowLimit = Struct.new(:limit, :interval, :count, keyword_init: true)

  AboveLimit = Struct.new(:limit, :interval, :count, keyword_init: true)

  def self.build
    new
  end

  def initialize(limit: 10, interval: 60, host: "redis", port: 6379, client: nil)
    @host = host
    @port = port
    @limit = limit
    @interval = interval
    @client = client

    set_client
  end

  def call(key)
    return unless @client

    begin
      count = @client.incr(key)
      @client.expire(key, @interval) if count == 1

      struct = count > @limit ? AboveLimit : BelowLimit
      struct.new(limit: @limit, interval: @interval, count: count)
    rescue Redis::CannotConnectError
      BFailure.new(errors: ["Could not connect to Redis Client"])
    end
  end

  private

  def set_client
    return if @client
    @client = ::Redis.new(host: @host, port: @port)
  end
end
