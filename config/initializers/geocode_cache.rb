require File.join(Rails.root, 'lib', 'yaml_config')

module GeocodeCacheInitializer
  def self.configure
    config = YamlConfig.load('geocode_cache')
    Rails.application.config.geocode_cache_db = config[:db]
  end
end

GeocodeCacheInitializer.configure
