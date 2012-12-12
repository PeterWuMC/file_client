require 'spec_helper'
require 'files'


describe Files::LocalFile do

  let(:path) { '/a/b/c.rb' }
  let(:key)  { Base64.strict_encode64(path) }

  context 'class methods' do

    context 'find' do

      it 'should return an object LocalFile' do
        FileManager.stub(:exists?).and_return(true)
        file = Files::LocalFile.find(key)

        file.should be_instance_of Files::LocalFile
      end

      it 'should return false if the file does not exists' do
        FileManager.stub(:exists?).and_return(false)
        file = Files::LocalFile.find(key)

        file.should == false
      end

      it 'should return false if the key is not strict base64 format' do
        FileManager.stub(:exists?).and_return(true)
        file = Files::LocalFile.find("HELLO")

        file.should == false
      end

    end

    context 'all' do

      it 'should return all the files in the local folder' do
        FileManager.should_receive(:all_files).once.and_return(["path1", "path2"])
        Files::LocalFile.all.each do |f|
          f.should be_instance_of Files::LocalFile
        end
      end

    end

  end

  context 'instance methods' do
    before(:each) { FileManager.stub(:exists?).and_return(true) }

    it 'should be able to return the path' do
      file = Files::LocalFile.find(key)
      file.path.should == path
    end

    it 'should be able to return the "last update" time stamp for the file' do
      FileManager.stub(:last_update).and_return(Time.new(2012,1,1,0,0,0,0).utc)
      file = Files::LocalFile.find(key)

      file.last_update.should == DateTime.new(2012,1,1)
    end

    it 'should be able to return file content' do
      file_content = "TEST"
      FileManager.stub(:read_from).and_return(file_content)
      file = Files::LocalFile.find(key)

      file.file_content.should == file_content
    end

    it 'should encode the file content to base64' do
      FileManager.should_receive(:read_from).with(anything(), anything(), {:base64 => true})

      Files::LocalFile.find(key).file_content
    end
  end

end
