module Extensions
  module Stripe
    def self.included base
      base.instance_eval do
        def execute_request(opts)
          StripeCache.new.fetch opts do
            RestClient::Request.execute(opts)
          end
        end
      end
    end
  end
end