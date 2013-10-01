require File.join(Rails.root, 'lib', 'yaml_config')

module JobsApiInitializer
  def self.configure
    config = YamlConfig.load('jobs_api')
    Rails.application.config.jobs_api_user = config[:user]
    Rails.application.config.jobs_api_pass = config[:pass]
  end
end

JobsApiInitializer.configure
