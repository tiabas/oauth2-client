module OAuth2
  module Client
    module Grant
      class RefreshToken < Base

        def initialize(client, refresh_token, opts={})
          super(client, opts)
          self[:refresh_token] = refresh_token
          self[:grant_type] = 'refresh_token'
        end

      end
    end
  end
end
