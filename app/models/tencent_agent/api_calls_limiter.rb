class TencentAgent
  module ApiCallsLimiter
    extend ActiveSupport::Concern

    included do
      class Tencent::Weibo::AccessToken
        def request_with_conform_calls_limitation(*args, &block)
          if TencentAgent.limitation_reached?
            raise Error, 'Tencent Weibo API calls limitation reached'
          else
            api_calls_count = api_calls_count + 1
            save
            $spider_logger.info "Tencent Weibo API calls count: #{api_calls_count}"
            request_without_conform_calls_limitation(*args, &block)
          end
        end

        alias_method_chain :request, :conform_calls_limitation
      end
    end

    module ClassMethods
      def reset_api_calls_count
        api_calls_count = 0
        save
        $spider_logger.info 'Reset Tencent Weibo API calls count'
      end

      def limitation_reached?
        api_calls_count >= 1000
      end
    end
  end
end
