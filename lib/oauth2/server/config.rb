module OAuth2
  module Server
    class Config

      attr_reader :token_datastore, :code_datastore, :client_datastore, :user_datastore 
    
      def initialize(config_file=nil)
        
        if Object.const_defined?(:Rails)
          config_file ||= "#{Rails.root}/config/oauth.yml"
          env = Rails.env
        end

        unless File.exists?(config_file)
          raise "Could not find #{config_file}"
        end

        params = YAML.load_file(config_file)

        datastores = params['datastores']
        
        @token_datastore = datastores['access_token'].constantize
        @code_datastore = datastores['authorization_code'].constantize
        @client_datastore = datastores['client_application'].constantize
        @user_datastore = datastores['user'].constantize
      end
    end
  end
end