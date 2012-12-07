require 'spec_helper'
require 'file_manager'

describe FileManager do

  context 'write_file' do

    let(:file) { mock() }
    let(:path) { "/a/b/c.rb" }

    before(:each) do
      File.should_receive(:open).with(path, 'w').and_yield(file)
    end

    it 'should write the content to the specific location' do
      file_content = "hello"

      FileManager.stub(:create_folders_for)
      file.should_receive(:write).with(file_content)

      FileManager.write_file(path, file_content)
    end

    it 'should request to create necessary folder structure if they are not exists' do
      FileManager.should_receive(:create_folders_for).with(path)
      file.stub(:write)

      FileManager.write_file(path, "")
    end

  end # context write_file

  context 'create_folders_for' do

    it 'should create all necessary folders' do
      File.stub(:directory?).and_return(false)
      Dir.should_receive(:mkdir).exactly(4).times

      FileManager.create_folders_for "/a/b/c/d/e.rb"
    end

  end # context create_folder_for

  context 'get_file_full_path' do

    it 'should append the client base folder if the target is client' do
      ConfigManager.should_receive(:get).once.with(:client_folder).and_return("/a/b/c")

      FileManager.get_file_full_path(:client, "d.rb").should == "/a/b/c/d.rb"
    end

    it 'should return the same path if the target is not client' do
      ConfigManager.should_not_receive(:get)

      FileManager.get_file_full_path(:full, "d.rb").should == "d.rb"
    end

  end # context get_file_full_path

  context 'exists?' do

    it 'should use absolute path to check if the file exists' do
      file = "/d/e.rb"
      FileManager.stub(:get_file_full_path).and_return("/a/b/c/d/e.rb")
      File.should_receive(:exists?).once.with("/a/b/c/d/e.rb").and_return(true)

      FileManager.exists?(:cllient, file)
    end

    it 'should raise an exception if the file not found' do
      file = "/a.rb"
      FileManager.stub(:get_file_full_path).and_return(file)
      File.should_receive(:exists?).once.with("/a.rb").and_return(false)

      expect{ FileManager.exists?(:full, file) }.to raise_error("File not found: #{file}")
    end

    it 'should raise an exception if the file not found and the raise_exception parameter is set' do
      file = "/a.rb"
      FileManager.stub(:get_file_full_path).and_return(file)
      File.should_receive(:exists?).once.with("/a.rb").and_return(false)

      expect{ FileManager.exists?(:full, file, true) }.to raise_error("File not found: #{file}")
    end

    it 'should not raise an exception if the file not found and the raise_exception parameter is set' do
      file = "/a.rb"
      FileManager.stub(:get_file_full_path).and_return(file)
      File.should_receive(:exists?).once.with("/a.rb").and_return(false)

      expect{ FileManager.exists?(:full, file, false) }.to_not raise_error
    end

  end # context exists?

  context 'last_update' do

    let(:file) { "/d/e.rb" }

    before(:each) do
      FileManager.stub(:exists?)
      FileManager.should_receive(:get_file_full_path).and_return(file)
    end

    it 'should return the correct Last Update time stamp' do
      File.should_receive(:mtime).once.with(file).and_return(Time.new(2012,1,1))

      FileManager.last_update(:cllient, file).should == DateTime.new(2012,1,1)
    end

  end # context last_update

  context 'read_from' do

    let(:file) { "/d/e.rb" }

    before(:each) do
      FileManager.stub(:exists?)
      FileManager.should_receive(:get_file_full_path).and_return(file)
    end

    it 'should return the exact content of the file' do
      File.should_receive(:read).once.with(file).and_return("TEST")

      FileManager.read_from(:client, file).should == "TEST"
    end

    it 'should encode the content using Base64 if required' do
      File.should_receive(:read).once.with(file).and_return("TEST")

      FileManager.read_from(:client, file, base64: true).should == Base64.encode64("TEST")
    end

  end # context read_from

  context 'write_to' do

    let(:file)         { "/d/e.rb" }
    let(:file_content) { "TEST" }

    before(:each) do
      FileManager.should_receive(:get_file_full_path).and_return(file)
    end

    it 'should write the exact content to the file' do
      FileManager.stub(:exists?).and_return(false)
      FileManager.should_receive(:write_file).with(file, file_content).once

      FileManager.write_to(:client, file, file_content)
    end

    it 'should overwrite the file if the overwrite flag is true' do
      FileManager.stub(:exists?).and_return(true)
      FileManager.should_receive(:write_file).with(file, file_content).once

      expect { FileManager.write_to(:client, file, file_content, overwrite: true) }.to_not raise_error
    end

    it 'should raise an exception if file already exists' do
      FileManager.stub(:exists?).and_return(true)
      FileManager.should_not_receive(:write_file)

      expect { FileManager.write_to(:client, file, file_content) }.to raise_error("File already exists: #{file}")
    end

    it 'should encode the content to base64 if the base64 flag is true' do
      FileManager.stub(:exists?).and_return(false)
      FileManager.should_receive(:write_file).with(file, file_content).once

      FileManager.write_to(:client, file, Base64.encode64(file_content), base64: true)
    end

    it 'should return the absolute path where the file are saved' do
      FileManager.stub(:exists?).and_return(false)
      FileManager.should_receive(:write_file).with(file, file_content).once

      FileManager.write_to(:client, file, file_content).should == file
    end

  end # context write_to
end