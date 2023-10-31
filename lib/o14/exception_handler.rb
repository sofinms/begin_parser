module O14
  class ExceptionHandler
    @logger = O14::ProjectLogger.get_logger

    def self.log_exception e, log_prefix = ''
      log_prefix = "#{log_prefix} " if !log_prefix.empty?
      @logger.error "#{log_prefix}#{ e.class.name } #{ e.message }"
      @logger.error "Exception Backtrace: #{ e.backtrace.join("\n") }"
    end
  end
end
