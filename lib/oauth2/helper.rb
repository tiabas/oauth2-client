require 'openssl'
require 'base64'

module OAuth2Client
  module Helper
     # convenience method to build response URI  
      def self.build_response_uri(uri, opts={})
        query= opts[:query]
        fragment= opts[:fragment]
        url = Addressable::URI.parse uri
        temp_query = url.query_values || {}
        temp_frag = url.fragment || nil
        url.query_values = temp_query.merge(query) unless query.nil?
        url.fragment = Addressable::URI.form_encode(fragment) unless fragment.nil?
        url.to_s
      end

    # Generate a random key of up to +size+ bytes. The value returned is Base64 encoded with non-word
    # characters removed.
    def generate_urlsafe_key(size=48)
      seed = Time.now.to_i
      size = size - seed.to_s.length
      Base64.encode64("#{ OpenSSL::Random.random_bytes(size) }#{ seed }").gsub(/\W/, '')
    end
    alias_method :generate_nonce, :generate_urlsafe_key

    def generate_timestamp #:nodoc:
      Time.now.to_i.to_s
    end

    def http_basic_encode(username, password)
      encoded_data = ["#{username}:#{password}"].pack("m0")
      "Basic #{encoded_data}"
    end

    # Convert a hash to a URI query string
    #
    # @params [Hash] params URI parameters
    def to_query(params)
      unless params.is_a?(Hash)
        raise "Expected Hash but got #{params.class.name}"
      end
      Addressable::URI.form_encode(params)
    end
  end
end