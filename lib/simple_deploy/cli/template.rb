require 'trollop'

module SimpleDeploy
  module CLI

    class Template
      include Shared

      def show
        @opts = Trollop::options do
          version SimpleDeploy::VERSION
          banner <<-EOS

Show current template for stack.

simple_deploy template -n STACK_NAME -e ENVIRONMENT

EOS
          opt :help, "Display Help"
          opt :environment, "Set the target environment", :type => :string
          opt :name, "Stack name to manage", :type => :string
        end

        valid_options? :provided => @opts,
                       :required => [:environment, :name]

        config = Config.new.environment @opts[:environment]

        stack = Stack.new :environment => @opts[:environment],
                          :name        => @opts[:name],
                          :config      => config,
                          :logger      => logger

        rescue_stackster_exceptions_and_exit do
          jj stack.template
        end
      end

      def logger
        @logger ||= SimpleDeployLogger.new :log_level => @opts[:log_level]
      end

      def command_summary
        'Show current template for stack'
      end

    end

  end
end
