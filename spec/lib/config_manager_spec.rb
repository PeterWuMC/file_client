require 'spec_helper'
require 'config_manager'

describe ConfigManager do
  before(:each) do
    Object.send(:remove_const, :ConfigManager)
    load 'config_manager.rb'
  end

  context 'config_full_path' do

    it 'should return the specify config path by appending it to the /{project directory}/config/{config file}.yml' do
      Dir.stub(:pwd).and_return("/a/b")

      ConfigManager.config_full_path("hello").should == "/a/b/config/hello.yml"
    end

  end # context config_full_page

  context 'save_files_version' do

    it 'should save the "files version" into version.yml in YAML format' do
      file_version = {"abc.rb" => {"server_last_update" => DateTime.new(2012, 1, 1), "local_last_update" => DateTime.new(2012,2,2)}}
      version_path = "/a/b/c.yml"

      ConfigManager.stub(:files_version).and_return(file_version)
      ConfigManager.stub(:config_full_path).and_return(version_path)
      FileManager.should_receive(:write_to).with(anything(), version_path, file_version.to_yaml, overwrite: true).once

      ConfigManager.save_files_version
    end

  end # context save_files_versionb

  context 'get_config' do

    it 'should return the content of a specify setting upon request' do
      ConfigManager.stub(:config).and_return({"test" => 123321})
      ConfigManager.get_config(:test).should == 123321
    end

    it 'should raise an exception if the the specify setting does not exists' do
      ConfigManager.stub(:config).and_return({})
      expect { ConfigManager.get_config(:test) }.to raise_error
    end

  end # context get_config

  context 'update_file_version' do

    it 'should create an entry for the file version' do
      ConfigManager.stub(:load_config_file).and_return({})

      ConfigManager.update_file_version("/a/b.rb", "test", "value")

      ConfigManager.files_version.should == {"/a/b.rb" => {"test" => "value"}}
    end

    it 'should update an entry for the file version' do
      ConfigManager.stub(:load_config_file).and_return({"/a/b.rb" => {"test" => "value"}})

      ConfigManager.update_file_version("/a/b.rb", "test", "nothing")

      ConfigManager.files_version.should == {"/a/b.rb" => {"test" => "nothing"}}
    end

    it 'should update the local_last_update if it specify as :local' do
      ConfigManager.stub(:load_config_file).and_return({})

      ConfigManager.update_file_version("/a/b.rb", :local, "value")

      ConfigManager.files_version.should == {"/a/b.rb" => {"local_last_update" => "value"}}
    end

    it 'should update the local_last_update if it specify as :server' do
      ConfigManager.stub(:load_config_file).and_return({})

      ConfigManager.update_file_version("/a/b.rb", :server, "value")

      ConfigManager.files_version.should == {"/a/b.rb" => {"server_last_update" => "value"}}
    end

  end # context update_file_version

  context 'load_config_file' do

    it 'should return an empty hash if the file does not exists' do
      FileManager.stub(:exists?).and_return(false)

      ConfigManager.load_config_file("test").should == {}
    end

    it 'should return an empty hash if the file is empty' do
      FileManager.stub(:exists?).and_return(true)
      FileManager.stub(:read_from).and_return("")

      ConfigManager.load_config_file("test").should == {}
    end

    it 'should return the hash of the config' do
      FileManager.stub(:exists?).and_return(true)
      FileManager.stub(:read_from).and_return({"a.rb" => {"test" => "value"}}.to_yaml)

      ConfigManager.load_config_file("test").should == {"a.rb" => {"test" => "value"}}
    end

  end # context load_config_file

  context 'config' do

    before(:each) do
      Object.send(:remove_const, :ConfigManager)
      load 'config_manager.rb'
    end

    it 'should return config if it was not previously loaded' do
      ConfigManager.should_receive(:load_config_file).once.with("setup").and_return({"a.rb" => {"test" => "value"}})

      ConfigManager.config.should == {"a.rb" => {"test" => "value"}}
    end

  end # context config

  context 'files_version' do

    before(:each) do
      ConfigManager.should_receive(:load_config_file).once.with("version").and_return({"a.rb" => {"test" => "value"}})
    end

    it 'should return config if it was not previously loaded' do
      ConfigManager.files_version.should == {"a.rb" => {"test" => "value"}}
    end

    it 'should return the files_version that is in the internet if its already initialised' do
      ConfigManager.update_file_version("a.rb", "test", "helloooooo")

      ConfigManager.files_version.should == {"a.rb" => {"test" => "helloooooo"}}
    end

  end # context files_version

end
