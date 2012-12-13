require 'logger'

class Log

  def self.this(postition=0, msg)
    msg = "[#{Time.now.utc.strftime("%Y/%m/%d %H:%M:%S")}] #{"  " * postition}#{msg}"
    puts msg
    logger.debug(msg)
  end

  private
    def self.logger
      @@logger ||= Logger.new("log/files.log")
    end

end
