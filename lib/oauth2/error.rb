require 'addressable/uri'

module OAuth2
  module OAuth2Error
    class Error < StandardError
      
      class << self; attr_accessor :code; end
      
      attr_reader :error, :error_description

      def initialize(msg=nil)
        msg ||= "an error occurred" 
        super msg
        @error = self.class.name
        @error_description = msg
      end

      def normalized_error
        # Taken from rails active support
        err = self.class.name.gsub(/^.*::/, '')
        err = err.gsub(/([A-Z\d]+)([A-Z][a-z])/,'\1_\2')
        err = err.gsub!(/([a-z\d])([A-Z])/,'\1_\2')
        err.downcase
      end

      def to_hash
        {
          :error             => normalized_error,
          :error_description => @error_description
        }
      end

      def to_txt
        "#{normalized_error}, #{@error_description}"
      end

      def to_uri_component
        Addressable::URI.form_encode to_hash
      end

      def redirect_uri(request)
        unless request.respond_to? :redirect_uri
          raise "#{request.class.name} does not respond to redirect_uri"
        end
        OAuth2::Helper.build_response_uri request.redirect_uri, :query => self.to_hash
      rescue Exception => e
        raise OAuth2::OAuth2Error::ServerError, e.message
      end
    end

    class AccessDenied < Error; end

    class InvalidClient < Error; end

    class InvalidGrant < Error; end

    class InvalidRequest < Error; end

    class InvalidScope < Error; end

    class ServerError < Error; end

    class UnauthorizedClient < Error; end

    class UnsupportedGrantType < Error; end

    class UnsupportedResponseType < Error; end

    class TemporarilyUnavailable < Error; end
  end
end