module Extensions
  module Stripe
    def self.included base
      base.instance_eval do

        alias _original_execute_request execute_request

        def execute_request(opts)
          res = StripeCache.new.fetch opts do
            RestClient::Request.execute(opts)
          end
          res.instance_eval do
            def body
              self
            end
          end
          res
        end
      end
    end
  end
end