require 'trollop'

module SimpleDeploy
  module CLI

    class List
      include Shared

      def stacks
        @opts = Trollop::options do
          version SimpleDeploy::VERSION
          banner <<-EOS

List stacks in an environment

simple_deploy list -e ENVIRONMENT

EOS
          opt :environment, "Set the target environment", :type => :string
          opt :log_level, "Log level:  debug, info, warn, error", :type    => :string,
                                                                  :default => 'info'
          opt :help, "Display Help"
        end

        valid_options? :provided => @opts,
                       :required => [:environment]

        config = Config.new.environment @opts[:environment]
        stacks = Stackster::StackLister.new(:config => config).all.sort

        stack = Stack.new :environment => @opts[:environment],
                          :name        => @opts[:name],
                          :config      => config,
                          :logger      => logger
        puts stacks
      end

      def logger
        @logger ||= SimpleDeployLogger.new :log_level => @opts[:log_level]
      end

      def command_summary
        'List stacks in an environment'
      end

    end

  end
end
