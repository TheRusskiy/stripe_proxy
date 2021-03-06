class StripeCache
  CACHE_CALLS = [
      {method: :get, url: /v1\/events(?:\/)?$/},
      {method: :get, url: /v1\/events\/(.+?)(?:\/)?$/}
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


  def cache_calls
    @cache_calls || CACHE_CALLS
  end

  def cache_calls= value
    @cache_calls = value
  end

  def should_cache? opts
    cache_calls.find{|c|
      method_matches = c[:method] == opts[:method]
      matches = opts[:url].match(c[:url])
      url_matches = matches && (matches.length == 1 || matches.to_a[1..-1].none?{|m| m.include?('/')})
      method_matches && url_matches
    }
  end

  ####################### PRIVATE ####################
  private

  def fetch_by_key key
    StripeCacheRecord.find_by_key(key).try(:value)
  end

  def store_by_key key, value
    record = begin
      StripeCacheRecord.new(key: key, value: value).tap(&:save!)
    rescue ActiveRecord::RecordNotUnique => e
      StripeCacheRecord.where(key: key).delete_all
      StripeCacheRecord.new(key: key, value: value).tap(&:save!)
    end
    record.value
  end
end