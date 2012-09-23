module OAuth2
  module DataStore
    class MockDataStore < Hash
      class << self
        attr_accessor :instances

        def find(attrs={})
          found = nil
          index = 0
          store = self.instances
          while index < store.length do
            match = true
            target = store[index] 
            attrs.each do |k, v|
              match = match & (target[k.to_sym] == v)
            end
            break if match
          end
          target
        end

      end
    end
  end
end

require 'oauth2/datastore/access_token_datastore'
require 'oauth2/datastore/authorization_code_datastore'
require 'oauth2/datastore/client_application_datastore'