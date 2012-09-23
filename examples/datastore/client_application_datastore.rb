module OAuth2
  module DataStore
    class ClientApplicationDataStore < MockDataStore

      CLIENT_TYPES = %w{ native web user-agent }
      
      attr_accessor :name, :website, :description, :client_type, :redirect_uri, :scope
      attr_reader :client_id, :client_secret

      def initialize(name, website, description, client_type, redirect_uri)
        super
        self.instances ||= []
        self.merge({
          :id => self.instances.length,
          :name => name,
          :website => website,
          :description => description,
          :client_type => client_type,
          :redirect_uri => redirect_uri,      
          :client_id => self.class.create_client_id,
          :client_secret => self.class.create_client_secret
        })
        self.class.instances << self
      end


    private

      def self.create_client_id
        OAuth2::Helper.generate_urlsafe_key(24)
      end

      def self.create_client_secret
        OAuth2::Helper.generate_urlsafe_key(32)
      end

      def authenticate(secret)
        self.client_secret == secret
      end
    end
  end
end