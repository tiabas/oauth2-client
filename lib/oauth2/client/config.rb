module OAuth2
  module Client
    class Config

      attr_reader :scheme, :host, :port, 
    
      def initialize(config_file=nil)
        
        if Object.const_defined?(:Rails)
          config_file ||= "#{Rails.root}/config/client.yml"
          env = Rails.env
        end

        unless File.exists?(config_file)
          raise "Could not find #{config_file}"
        end

        config = YAML.load_file(config_file)

        @scheme = config[:scheme]
        @host   = config[:host]
        @port   = config[:port]
      end
    end
  end
end