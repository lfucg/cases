module GeocodeCache
  class << self
    def redis
      @redis ||= Redis.new(host: Rails.application.config.redis_host,
                           port: Rails.application.config.redis_port,
                           db: Rails.application.config.geocode_cache_db)
    end

    def [](location)
      if val = redis.get(location)
        JSON.parse(val)
      end
    end

    def []=(location, coords)
      redis.set(location, JSON.generate(coords))
    end
  end
end
