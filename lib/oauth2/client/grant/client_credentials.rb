module OAuth2
  module Client
    module Grant
      class ClientCredentials < Base

        def initialize(client, opts={})
          super(client, opts)
          self[:grant_type] = 'client_credentials'
        end

      end
    end
  end
end
