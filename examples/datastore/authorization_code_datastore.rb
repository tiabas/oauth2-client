module OAuth2
  module DataStore
    class AuthorizationCodeDataStore < MockDataStore

        private_class_method :new

        class << self
          include OAuth2::Helper

          def self.generate_authorization_code(c_id, redirect)
            self.instances ||= []
            kode = new
            kode.merge!({
                  :id => self.instances.length,
                  :code => generate_urlsafe_key,
                  :redirect_uri => redirect,
                  :client_id => c_id,
                  :deactivated_at => nil,
                  :created_at => Time.now
                })
            self.instances << kode
          end

          def self.fetch_authorization_code(c_id, auth_code, redirect)
            kode = find :client_id => c_id, :code => auth_code,:redirect_uri => redirect
          end
        end

        def deactivate!
          self[:deactivated_at] = Time.now
          save
        end

        def expired? 
          Time.now > self[:created_at]+600 
        end

        def inactive?
          !!self[:deactivated_at]
        end

        def active?
          !inactive?
        end
    end
  end
end