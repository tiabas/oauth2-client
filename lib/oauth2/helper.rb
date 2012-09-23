require 'openssl'
require 'base64'

module OAuth2
  module Helper
     # convenience method to build response URI  
      def self.build_response_uri(redirect_uri, opts={})
        query= opts[:query]
        fragment= opts[:fragment]
        uri = Addressable::URI.parse redirect_uri
        temp_query = uri.query_values || {}
        temp_frag = uri.fragment || nil
        uri.query_values = temp_query.merge(query) unless query.nil?
        uri.fragment = Addressable::URI.form_encode(fragment) unless fragment.nil?
        uri.to_s
      end

    # Escape +value+ by URL encoding all non-reserved character.
    #
    # See Also: {OAuth core spec version 1.0, section 5.1}[http://oauth.net/core/1.0#rfc.section.5.1]
    def escape(value)
      URI::escape(value.to_s, OAuth::RESERVED_CHARACTERS)
    rescue ArgumentError
      URI::escape(value.to_s.force_encoding(Encoding::UTF_8), OAuth::RESERVED_CHARACTERS)
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

    # Parse an Authorization / WWW-Authenticate header into a hash. Takes care of unescaping and
    # removing surrounding quotes. Raises a OAuth::Problem if the header is not parsable into a
    # valid hash. Does not validate the keys or values.
    #
    #   hash = parse_header(headers['Authorization'] || headers['WWW-Authenticate'])
    #   hash['oauth_timestamp']
    #     #=>"1234567890"
    #
    def parse_header(header)
      # decompose
      params = header[6,header.length].split(/[,=&]/)

      # odd number of arguments - must be a malformed header.
      raise OAuth::Error.new("Invalid authorization header") if params.size % 2 != 0

      params.map! do |v|
        # strip and unescape
        val = unescape(v.strip)
        # strip quotes
        val.sub(/^\"(.*)\"$/, '\1')
      end

      # convert into a Hash
      Hash[*params.flatten]
    end

    def unescape(value)
      URI.unescape(value.gsub('+', '%2B'))
    end
  end
end