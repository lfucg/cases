require 'yaml'
geocode_cache_config = YAML::load_file(File.expand_path(File.join(File.dirname(__FILE__), '..', 'geocode_cache.yml')))
Rails.application.config.geocode_cache_db = geocode_cache_config[:db]
