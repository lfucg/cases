module MailConfig

  def self.apply_smtp_settings
    config = YamlConfig.load('mailer')
    settings = {}
    %w(address port domain user_name password authentication enable_starttls_auto).each do |setting|
      settings[setting.to_sym] = config[setting]
    end
    Rails.application.config.action_mailer.smtp_settings = settings
  end
end
