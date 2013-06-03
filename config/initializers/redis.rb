require 'yaml'
redis_config = YAML::load_file(File.expand_path(File.join(File.dirname(__FILE__), '..', 'redis.yml')))
Rails.application.config.redis_host = redis_config[:host]
Rails.application.config.redis_port = redis_config[:port]
