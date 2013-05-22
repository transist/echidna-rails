class TencentAgent
  module TencentLogger
    extend ActiveSupport::Concern

    included do
      def self.logger
        @logger ||= Logger.new('log/spider.log', 10, 1024000)
      end
    end

    def info(message)
      self.class.logger.info(log_wrapper(message))
    end

    def warn(message)
      self.class.logger.warn(log_wrapper(message))
    end

    def error(message)
      self.class.logger.error(log_wrapper(message))
    end

    # Log unexpected errors to a redis list
    def log_unexpected_error(exception)
      error = {
        class: exception.class.name,
        message: exception.message,
        backtrace: exception.backtrace,
        raised_at: Time.now
      }
      if exception.respond_to?(:response)
        faraday_response = exception.response.response.to_hash
        # Delete self-reference
        faraday_response.delete(:response)
        faraday_response[:url] = faraday_response[:url].to_s
        faraday_response[:body] = MultiJson.load(faraday_response[:body]) rescue faraday_response[:body]

        error[:response] = faraday_response
      end

      error(error)
      info(exception.inspect)
    end

    def log_wrapper(message)
      "#{Time.now.to_s} Tencent Weibo agent #{name}: #{message}"
    end
  end
end