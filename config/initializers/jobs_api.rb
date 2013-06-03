require 'yaml'
jobs_config = YAML::load_file(File.expand_path(File.join(File.dirname(__FILE__), '..', 'jobs_api.yml')))
Rails.application.config.jobs_api_user = jobs_config[:user]
Rails.application.config.jobs_api_pass = jobs_config[:pass]
