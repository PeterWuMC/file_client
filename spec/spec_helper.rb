$:.unshift File.join(Dir.pwd, 'models')
$:.unshift File.join(Dir.pwd, 'lib')
require 'base64'
require 'log'

RSpec.configure do |config|
  config.before :each do
  	File.stub(:open)
  	Log.stub(:this)
  end
end