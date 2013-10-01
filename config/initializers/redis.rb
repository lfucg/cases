require File.join(Rails.root, 'lib', 'yaml_config')

module RedisInitializer
  def self.configure
    config = YamlConfig.load('redis')
    Rails.application.config.redis_host = config[:host]
    Rails.application.config.redis_port = config[:port]
  end
end

RedisInitializer.configure
