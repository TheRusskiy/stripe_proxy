require 'rspec'

describe StripeCache do

  it 'can call original method' do
    service = double('Original Service')
    expect(service).to receive(:original_method)
    StripeCache.new.fetch(method: :get, url: 'https://google.com') do
      service.original_method
    end
  end

  it 'can cache results' do
    stripe_cache = StripeCache.new
    allow(stripe_cache).to receive(:should_cache?).and_return(true)
    service = double('Original Service')
    allow(service).to receive(:original_method).and_return(1, 2)
    first_result = stripe_cache.fetch(method: :get, url: 'https://google.com') do
      service.original_method
    end
    second_result = stripe_cache.fetch(method: :get, url: 'https://google.com') do
      service.original_method
    end
    expect(first_result).to be_truthy
    expect(first_result).to eq(second_result)
  end

  it 'can cache patterns' do
    stripe_cache = StripeCache.new
    stripe_cache.cache_calls = [
        {method: :get, url: /v1\/customers(?:\/)?$/},
        {method: :get, url: /v1\/customers\/(.+?)(?:\/)?$/}
    ]

    expect(stripe_cache.should_cache?(method: :get, url: 'https://api.stripe.com/v1/customers')).to be_truthy
    expect(stripe_cache.should_cache?(method: :get, url: 'https://api.stripe.com/v1/customers/')).to be_truthy
    expect(stripe_cache.should_cache?(method: :get, url: 'https://api.stripe.com/v1/customersS')).to be_falsey
    expect(stripe_cache.should_cache?(method: :get, url: 'https://api.stripe.com/v1/customers/XXX')).to be_truthy
    expect(stripe_cache.should_cache?(method: :get, url: 'https://api.stripe.com/v1/customers/XXX/xxx')).to be_falsey

    service = double('Original Service')
    allow(service).to receive(:original_method).and_return(1, 2, 3)
    r1 = stripe_cache.fetch(method: :get, url: 'https://api.stripe.com/v1/customers/XXX') do
      service.original_method
    end
    r2 = stripe_cache.fetch(method: :get, url: 'https://api.stripe.com/v1/customers/XXX') do
      service.original_method
    end
    r3 = stripe_cache.fetch(method: :get, url: 'https://api.stripe.com/v1/customers/YYY') do
      service.original_method
    end

    expect(r1).to be_truthy
    expect(r2).to be_truthy
    expect(r3).to be_truthy
    expect(r1).to eq(r2)
    expect(r1).not_to eq(r3)
  end
end