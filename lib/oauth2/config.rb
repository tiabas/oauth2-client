module OAuth2Client
  class Config

    attr_reader :properties, :env 

    def initialize(opts)
      filename = opts[:filename]
      config = YAML.load_file(filename)
      @service = opts[:service].to_s
      @env = (opts[:env] || Rails.env).to_s
      @properties = config[env][@service]
      define_methods_for_client(@properties.keys)
    end

    def define_methods_for_client(keys)
      keys.each do |key|
        self.class.class_eval do
           define_method key do
            @properties[key]
          end
        end
      end
    end
  end
end