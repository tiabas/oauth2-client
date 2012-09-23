module OAuth2
  module Client
    module Grant
      class Password < Base

        def initialize(client, username, password, opts={})
          super(client, opts)
          self[:username]   = username
          self[:password]   = password
          self[:grant_type] = 'password'
        end

        def username
          self[:username]
        end

        def password
          self[:password]
        end

        def username=(username)
          self[:username] = username
        end

        def password=(password)
          self[:password] = password
        end

      end
    end
  end
end
