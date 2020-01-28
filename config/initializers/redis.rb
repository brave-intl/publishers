Redis::Objects.redis = ConnectionPool.new(size: 20, timeout: 5) { REDIS }
