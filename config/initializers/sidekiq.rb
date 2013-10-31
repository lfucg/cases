require 'sidekiq/web'
require File.join(Rails.root, 'lib', 'yaml_config')

module SidekiqInitializer
  def self.configure
    config = YamlConfig.load('sidekiq')

    Sidekiq.configure_server do |cfg|
      cfg.redis = { url: config[:redis_url] }
    end

    Sidekiq.configure_client do |cfg|
      cfg.redis = { url: config[:redis_url] }
    end

    Sidekiq::Web.use(Rack::Auth::Basic) do |u, p|
      [u, p] == [config[:user], config[:pass]]
    end
  end
end

SidekiqInitializer.configure
