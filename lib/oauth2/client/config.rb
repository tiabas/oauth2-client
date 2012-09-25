module OAuth2
  module Client
    class Config

      attr_reader :properties, :env 

      def initialize(opts)
        config_filename = opts[:filename]
        @service = opts[:service]
        @env = opts[:env] ||= Rails.env
        @properties = YAML.load_file(File.join('config', config_filename))
        service = properties[env][service]
        define_methods_for_client(service.keys)
      end

      def define_methods_for_environment(keys)
        keys.each do |key|
          class_eval <<-EOS
            def #(name)
              properties[#{key}]
            end
          EOS
        end
      end
    end
  end
end