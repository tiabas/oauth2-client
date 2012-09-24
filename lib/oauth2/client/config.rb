module OAuth2
  module Client
    class Config

      attr_reader :scheme, :host, :port, 
    
      def initialize(config_file=nil)
        
        if Object.const_defined?(:Rails)
          config_file ||= "#{Rails.root}/config/oauth_client.yml"
          env = Rails.env
        end

        unless File.exists?(config_file)
          raise "Could not find #{config_file}"
        end

        config = YAML.load_file(config_file)

        @scheme         = config[:scheme]
        @host           = config[:host]
        @port           = config[:port]
        @token_path     = config[:token_path]
        @authorize_path = config[:authorize_path]
        @http_client    = config[:http_client]
      end
    end
  end
end