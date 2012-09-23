module OAuth2
  module Client
    module Grant
      class AuthorizationCode < Base

        def initialize(client, code, opts={})
          super(client, opts)
          self[:code] = code
          self[:grant_type] = 'authorization_code'
        end

      end
    end
  end
end
