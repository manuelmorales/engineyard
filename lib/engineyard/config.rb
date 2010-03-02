module EY
  class Config
    CONFIG_FILE = "cloud.yml"

    def initialize(file=CONFIG_FILE)
      require 'yaml'
      @config = YAML.load_file(file)
    rescue Errno::ENOENT # no cloud.yml
      @config = {}
    ensure
      @config.merge!("environments" => {}) unless @config["environments"]
    end

    def method_missing(meth, *args, &blk)
      key = meth.to_s.downcase
      if @config.key?(key)
        @config[key]
      else
        super
      end
    end

    def respond_to?(meth)
      key = meth.to_s.downcase
      @config.key?(key) || super
    end

    def endpoint
      @endpoint ||= (
        @config["endpoint"] ||
        ENV["CLOUD_URL"] ||
        default_endpoint
      ).chomp("/")
    end

    def default_endpoint
      "https://cloud.engineyard.com"
    end

    def default_endpoint?
      default_endpoint == endpoint
    end

    def default_environment
      d = environments.find do |name, env|
        env["default"]
      end
      d && d.first
    end

    def default_branch(environment = default_environment)
      env = environments[environment]
      env && env["branch"]
    end
  end
end