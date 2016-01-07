class StripeCache
  CACHE_CALLS = [
      {method: :get, url: 'https://api.stripe.com/v1/customers'}
  ]

  def fetch opts, &block
    if should_cache?(opts)
      key = "#{opts[:method]}_#{opts[:url]}"
      result = fetch_by_key key
      unless result
        result = store_by_key key, block.call
      end
      result
    else
      block.call
    end
  end


  def should_cache? opts
    CACHE_CALLS.find{|c| c[:method] == opts[:method] && c[:url] == opts[:url]}
  end

  ####################### PRIVATE ####################
  private

  SIMPLE_STORE = {}
  def fetch_by_key key
    SIMPLE_STORE[key]
  end

  def store_by_key key, value
    SIMPLE_STORE[key] = value
  end
end