
require 'spec_helper'
require 'simple_deploy/cli'

describe SimpleDeploy::CLI::Deploy do
  describe 'deploy' do
    before do
      @logger   = stub 'logger', 'info' => 'true', 'error' => 'true'
      @stack    = stub :attributes => {}
      @notifier = stub

      SimpleDeploy::SimpleDeployLogger.should_receive(:new).
                                       with(:log_level => 'debug').
                                       and_return(@logger)
    end

    it "should notify on success" do
      options = { :environment => 'my_env',
                  :log_level   => 'debug',
                  :name        => ['my_stack'],
                  :force       => true,
                  :internal    => false,
                  :attributes  => [] }

      subject.should_receive(:valid_options?).
              with(:provided => options,
                   :required => [:environment, :name])
      Trollop.stub(:options).and_return(options)

      SimpleDeploy::Notifier.should_receive(:new).
                          with(:stack_name  => 'my_stack',
                               :environment => 'my_env',
                               :logger      => @logger).
                          and_return(@notifier)

      SimpleDeploy::Stack.should_receive(:new).
                          with(:environment => 'my_env',
                               :logger      => @logger,
                               :name        => 'my_stack',
                               :internal    => false).
                          and_return(@stack)

      @stack.should_receive(:wait_for_stable)
      @stack.should_receive(:deploy).with(true).and_return(true)
      @notifier.should_receive(:send_deployment_start_message)
      @notifier.should_receive(:send_deployment_complete_message)

      subject.deploy
    end

    it "should exit on error with a status of 1" do
      options = { :environment => 'my_env',
                  :log_level   => 'debug',
                  :name        => ['my_stack'],
                  :force       => true,
                  :internal    => false,
                  :attributes  => [] }

      subject.should_receive(:valid_options?).
              with(:provided => options,
                   :required => [:environment, :name])
      Trollop.stub(:options).and_return(options)

      SimpleDeploy::Notifier.should_receive(:new).
                          with(:stack_name  => 'my_stack',
                               :environment => 'my_env',
                               :logger      => @logger).
                          and_return(@notifier)

      SimpleDeploy::Stack.should_receive(:new).
                          with(:environment => 'my_env',
                               :logger      => @logger,
                               :name        => 'my_stack',
                               :internal    => false).
                          and_return(@stack)

      @stack.should_receive(:wait_for_stable)
      @stack.should_receive(:deploy).with(true).and_return(false)
      @notifier.should_receive(:send_deployment_start_message)

      begin
        subject.deploy
      rescue SystemExit => e
        e.status.should == 1
      end
    end

    it "should update the deploy attributes if any are passed" do
      options = { :environment => 'my_env',
                  :log_level   => 'debug',
                  :name        => ['my_stack'],
                  :force       => true,
                  :internal    => false,
                  :attributes  => ['foo=bah'] }

      subject.should_receive(:valid_options?).
              with(:provided => options,
                   :required => [:environment, :name])
      Trollop.stub(:options).and_return(options)

      SimpleDeploy::Notifier.should_receive(:new).
                          with(:stack_name  => 'my_stack',
                               :environment => 'my_env',
                               :logger      => @logger).
                          and_return(@notifier)

      SimpleDeploy::Stack.should_receive(:new).
                          with(:environment => 'my_env',
                               :logger      => @logger,
                               :name        => 'my_stack',
                               :internal    => false).
                          and_return(@stack)

      @stack.should_receive(:update).with(hash_including(:force => true, :attributes => [{'foo' => 'bah'}])).and_return(true)
      @stack.should_receive(:wait_for_stable)
      @stack.should_receive(:deploy).with(true).and_return(true)
      @notifier.should_receive(:send_deployment_start_message)
      @notifier.should_receive(:send_deployment_complete_message)

      subject.deploy
    end

    it "should exit with a status of 1 if the attributes update is not successful" do
      options = { :environment => 'my_env',
                  :log_level   => 'debug',
                  :name        => ['my_stack'],
                  :force       => true,
                  :internal    => false,
                  :attributes  => ['foo=bah'] }

      subject.should_receive(:valid_options?).
              with(:provided => options,
                   :required => [:environment, :name])
      Trollop.stub(:options).and_return(options)

      SimpleDeploy::Notifier.should_receive(:new).
                          with(:stack_name  => 'my_stack',
                               :environment => 'my_env',
                               :logger      => @logger).
                          and_return(@notifier)

      SimpleDeploy::Stack.should_receive(:new).
                          with(:environment => 'my_env',
                               :logger      => @logger,
                               :name        => 'my_stack',
                               :internal    => false).
                          and_return(@stack)

      @stack.should_receive(:update).with(hash_including(:force => true,
                                                         :attributes => [{'foo' => 'bah'}])).and_return(false)
      @stack.should_receive(:wait_for_stable)

      begin
        subject.deploy
      rescue SystemExit => e
        e.status.should == 1
      end
    end

    it "should do the deploy if there are no attributes to update" do
      options = { :environment => 'my_env',
                  :log_level   => 'debug',
                  :name        => ['my_stack'],
                  :force       => true,
                  :internal    => false,
                  :attributes  => [] }

      subject.should_receive(:valid_options?).
              with(:provided => options,
                   :required => [:environment, :name])
      Trollop.stub(:options).and_return(options)

      SimpleDeploy::Notifier.should_receive(:new).
                          with(:stack_name  => 'my_stack',
                               :environment => 'my_env',
                               :logger      => @logger).
                          and_return(@notifier)

      SimpleDeploy::Stack.should_receive(:new).
                          with(:environment => 'my_env',
                               :logger      => @logger,
                               :name        => 'my_stack',
                               :internal    => false).
                          and_return(@stack)

      @stack.should_not_receive(:update)
      @stack.should_receive(:wait_for_stable)
      @stack.should_receive(:deploy).with(true).and_return(true)
      @notifier.should_receive(:send_deployment_start_message)
      @notifier.should_receive(:send_deployment_complete_message)

      subject.deploy
    end
  end
end
