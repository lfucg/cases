require 'sidekiq/web'
require File.join(Rails.root, 'lib', 'yaml_config')

module SidekiqInitializer
  def self.configure
    config = YamlConfig.load('sidekiq')
    Sidekiq::Web.use(Rack::Auth::Basic) do |u, p|
      [u, p] == [config[:user], config[:pass]]
    end
  end
end

SidekiqInitializer.configure
