require 'spec_helper'
require 'files'


describe Files::ServerFile do

  let(:path) { '/a/b/c.rb' }
  let(:key)  { Base64.strict_encode64(path) }

  context 'download' do
    before(:each) do
      ActiveResource::HttpMock.respond_to do |mock|
        mock.get "/server_files.json",  {}, [{a: "1", b: "2"}].to_json
        mock.get "/server_files/#{key}.json", {}, {key: key, path: path, last_update: DateTime.new(2012,1,1)}.to_json
        mock.get "/server_files/#{key}/download.json", {}, {key: key, path: path, file_content: "file_content"}.to_json

        mock.get "/server_files/nothing.json", {}, nil, 404
      end

    end

    it 'should write the content to file system' do
      FileManager.should_receive(:write_to)

      file = Files::ServerFile.find(key)
      file.download
    end

    it 'should return false if nothing is found' do
      file = Files::ServerFile.find("nothing")
      file.should == false
    end

  end

end