begin
  require 'net/https'
rescue LoadError
  warn "Warning: no such file to load -- net/https. Make sure openssl is installed if you want ssl support"
  require 'net/http'
end
require 'zlib'
require 'addressable/uri'

module OAuth2Client
  class HttpConnection

    class UnhandledHTTPMethodError < StandardError; end
    class UnsupportedSchemeError < StandardError; end

    NET_HTTP_EXCEPTIONS = [
      EOFError,
      Errno::ECONNABORTED,
      Errno::ECONNREFUSED,
      Errno::ECONNRESET,
      Errno::EINVAL,
      Net::HTTPBadResponse,
      Net::HTTPHeaderSyntaxError,
      Net::ProtocolError,
      SocketError,
      Zlib::GzipFile::Error,
    ]

    attr_accessor :config, :scheme, :host, :port, :max_redirects, :ssl,
                  :user_agent, :accept, :max_redirects, :headers

    def self.default_options
      {
        :headers => {
          'Accept'     => 'application/json',
          'User-Agent' => "OAuth2 Ruby Gem #{OAuth2Client::Version}"
        },
        :ssl => {:verify => true},
        :max_redirects => 5
      }
    end

    def initialize(url, options={})
      @uri = Addressable::URI.parse(url)
      self.class.default_options.keys.each do |key|
        instance_variable_set(:"@#{key}", options.fetch(key, self.class.default_options[key]))
      end
    end

    def default_headers
      self.class.default_options[:headers]
    end

    def scheme=(scheme)
      unless ['http', 'https'].include? scheme
        raise UnsupportedSchemeError.new "#{scheme} is not supported, only http and https"
      end
      @scheme = scheme
    end

    def scheme
      @scheme ||= @uri.scheme
    end

    def host
      @host ||= @uri.host
    end

    def port
      _port = ssl? ? 443 : 80
      @port = @uri.port || _port
    end

    def absolute_url(path='')
      "#{scheme}://#{host}#{path}"
    end

    def ssl?
      scheme == "https" ? true : false
    end

    def ssl=(opts)
      raise "Expected Hash but got #{opts.class.name}" unless opts.is_a?(Hash)
      @ssl.merge!(opts)
    end

    def http_connection(opts={})
      _host   = opts[:host]   || host
      _port   = opts[:port]   || port
      _scheme = opts[:scheme] || scheme

      @http_client = Net::HTTP.new(_host, _port)

      configure_ssl(@http_client) if _scheme == 'https'

      @http_client
    end

    def send_request(method, path, opts={})
      headers         = @headers.merge(opts.fetch(:headers, {}))
      params          = opts[:params] || {}
      query           = Addressable::URI.form_encode(params)
      method          = method.to_sym
      normalized_path = query.empty? ? path : [path, query].join("?")
      client          = http_connection(opts.fetch(:connection_options, {}))

      if (method == :post || method == :put)
        headers['Content-Type'] ||= 'application/x-www-form-urlencoded'
      end

      case method
      when :get, :delete
        response = client.send(method, normalized_path, headers)
      when :post, :put
        response = client.send(method, path, query, headers)
      else
        raise UnhandledHTTPMethodError.new("Unsupported HTTP method, #{method}")
      end

      status = response.code.to_i

      case status
      when 301, 302, 303, 307
        unless redirect_limit_reached?
          if status == 303
            method = :get
            params = nil
            headers.delete('Content-Type')
          end
          redirect_uri = Addressable::URI.parse(response.header['Location'])
          conn = {
            :scheme => redirect_uri.scheme,
            :host   => redirect_uri.host,
            :port   => redirect_uri.port
          }
          return send_request(method, redirect_uri.path, :params => params, :headers => headers, :connection_options => conn)
        end
      when 100..599
        @redirect_count = 0
      else
        raise "Unhandled status code value of #{response.code}"
      end
      response
    rescue *NET_HTTP_EXCEPTIONS
      raise "Error::ConnectionFailed, $!"
    end

  private

    def configure_ssl(http)
      http.use_ssl      = true
      http.verify_mode  = ssl_verify_mode
      http.cert_store   = ssl_cert_store

      http.cert         = ssl[:client_cert]  if ssl[:client_cert]
      http.key          = ssl[:client_key]   if ssl[:client_key]
      http.ca_file      = ssl[:ca_file]      if ssl[:ca_file]
      http.ca_path      = ssl[:ca_path]      if ssl[:ca_path]
      http.verify_depth = ssl[:verify_depth] if ssl[:verify_depth]
      http.ssl_version  = ssl[:version]      if ssl[:version]
    end

    def ssl_verify_mode
      if ssl.fetch(:verify, true)
          OpenSSL::SSL::VERIFY_PEER
      else
          OpenSSL::SSL::VERIFY_NONE
      end
    end

    def ssl_cert_store
      return ssl[:cert_store] if ssl[:cert_store]
      cert_store = OpenSSL::X509::Store.new
      cert_store.set_default_paths
      cert_store
    end

    def redirect_limit_reached?
      @redirect_count ||= 0
      @redirect_count += 1
      @redirect_count > @max_redirects
    end
  end
end
