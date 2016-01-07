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
end