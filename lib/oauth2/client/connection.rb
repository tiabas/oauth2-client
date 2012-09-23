begin
  require 'net/https'
rescue LoadError
  warn "Warning: no such file to load -- net/https. Make sure openssl is installed if you want ssl support"
  require 'net/http'
end
require 'zlib'
require 'addressable/uri'

module OAuth2
  module Client
    class Connection
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
      
      attr_accessor :scheme, :host, :port, :max_redirects, :ssl
      
      def initialize(scheme, host, opts={})
        @scheme = scheme
        @host = host
        @port = opts[:port]
        @max_redirects = opts[:max_redirects] || 5
        @ssl = opts[:ssl] || {}
      end
      
      def scheme=(scheme)
        unless ['http', 'https'].include? scheme
          raise "The scheme #{scheme} is not supported. Only http and https are supported"
        end
        @scheme = scheme
      end

      def use_ssl
        @scheme == "https" ? true : false
      end

      def configure_ssl(http, ssl)
        http.use_ssl      = true
        http.verify_mode  = ssl_verify_mode(ssl)
        http.cert_store   = ssl_cert_store(ssl)

        http.cert         = ssl[:client_cert]  if ssl[:client_cert]
        http.key          = ssl[:client_key]   if ssl[:client_key]
        http.ca_file      = ssl[:ca_file]      if ssl[:ca_file]
        http.ca_path      = ssl[:ca_path]      if ssl[:ca_path]
        http.verify_depth = ssl[:verify_depth] if ssl[:verify_depth]
        http.ssl_version  = ssl[:version]      if ssl[:version]
      end

      def ssl_verify_mode(ssl)
        ssl[:verify_mode] || begin
          if ssl.fetch(:verify, false)
            OpenSSL::SSL::VERIFY_PEER
          else
          OpenSSL::SSL::VERIFY_NONE
          end
        end
      end

      def ssl_cert_store(ssl)
        return ssl[:cert_store] if ssl[:cert_store]
        cert_store = OpenSSL::X509::Store.new
        cert_store.set_default_paths
        cert_store
      end

      def http_connection 
        @http_client = Net::HTTP.new(@host, @port)
        if use_ssl
          configure_ssl(@http_client, @ssl)
        end
        @http_client
      end

      def send_request(path, params, method, headers={})
        connection = http_connection

        case method.to_s.downcase
        when 'get'
          query = params ? Addressable::URI.form_encode(params) : nil
          uri = query ? [path, query].join("?") : path
          response = connection.get(uri, headers)
        when 'post'
          response = connection.post(path, params, headers)
        when 'put'
          response = connection.put(path, params, headers)
        when 'delete'
          response = connection.delete(path, params, headers)
        else
          raise "Unsupported HTTP method, #{method}"
        end
        status = response.code.to_i
        case status
        when 301, 302, 303, 307
          return response if redirect_limit_reached?
          if status == 303
            method = :get
            params = nil
          end
          uri = Addressable::URI.parse(response.header['Location'])
          @scheme = uri.scheme
          @host = uri.host
          @port = uri.port
          send_request(uri.path, params, method)
        when 200..599
          response
        else
          raise "Unhandled status code value of #{response.code}"
        end
      rescue *NET_HTTP_EXCEPTIONS
        raise "Error::ConnectionFailed, $!"
      end

      def redirect_limit_reached?
          @redirect_count ||= 0
          @redirect_count += 1
          @redirect_count > @max_redirects
      end
    end
  end
end
