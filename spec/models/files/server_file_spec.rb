require 'spec_helper'
require 'files'


describe Files::ServerFile do

  context 'download' do
    before(:each) do
      @file = "/a/b/c.rb"
      ActiveResource::HttpMock.respond_to do |mock|
        mock.get "/server_files.json",  {}, [{a: "1", b: "2"}].to_json
        mock.get "/server_files/#{@file}.json", {}, {path: @file, last_update: DateTime.new(2012,1,1)}.to_json
        mock.get "/server_files/#{@file}/download.json", {}, {path: @file, file_content: "file_content"}.to_json
      end

    end

    it 'should write the content to file system' do
      FileManager.should_receive(:write_to)

      file = Files::ServerFile.find(@file)
      file.download
    end
  end

end