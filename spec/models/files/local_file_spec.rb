require 'spec_helper'
require 'files'


describe Files::LocalFile do
  before(:each) do
    FileManager.stub(:exists?).and_return(true)
  end

  context 'class methods' do
    context 'find' do
      it 'should return an object LocalFile' do
        file = Files::LocalFile.find('/a/b/c.rb')
        file.should be_instance_of Files::LocalFile
      end
    end
  end

  context 'instance methods' do
    it 'should be able to return the path' do
      path = '/a/b/c.rb'

      file = Files::LocalFile.find(path)
      file.path.should == path
    end

    it 'should be able to return the "last update" time stamp for the file' do
      FileManager.stub(:last_update).and_return(Time.new(2012,1,1))
      file = Files::LocalFile.find('/a/b/c.rb')

      file.last_update.should == DateTime.new(2012,1,1)
    end

    it 'should be able to return file content' do
      file_content = "TEST"
      FileManager.stub(:read_from).and_return(file_content)
      file = Files::LocalFile.find('/a/b/c.rb')

      file.file_content.should == file_content
    end

    it 'should encode the file content to base64' do
      FileManager.should_receive(:read_from).with(anything(), anything(), {:base64 => true})

      Files::LocalFile.find('/a/b/c.rb').file_content
    end
  end

end