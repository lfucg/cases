module YamlConfig
  
  def self.load(name)
    yaml_config(name)
  end

  private

  def self.yaml_config(name)
    yaml(File.join(config_path, "#{name}.yml"))
  end

  def self.yaml(path)
    YAML::load_file(path)
  end

  def self.config_path
    File.join(Rails.root, 'config')
  end
end
