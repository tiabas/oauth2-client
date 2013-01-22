require 'openssl'
require 'base64'

module OAuth2
  module UrlHelper
    # convenience method to build response URI  
    def build_uri(uri, opts={})
      query_params= opts[:params] || {}
      fragment= opts[:fragment] || {}
      url = Addressable::URI.parse uri

      url.query_values = new_query unless new_query.empty?
      url.fragment = Addressable::URI.form_encode(fragment) unless fragment.empty?
      url.to_s
    end

    # generates a random key of up to +size+ bytes. The value returned is Base64 encoded with non-word
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
    module_function :http_basic_encode

    # converts a hash to a URI query string
    # @params [Hash] params URI parameters
    def to_query(params)
      unless params.is_a?(Hash)
        raise "Expected Hash but got #{params.class.name}"
      end
      Addressable::URI.form_encode(params)
    end
  end
end