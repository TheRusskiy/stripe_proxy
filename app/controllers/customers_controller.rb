class CustomersController < ApplicationController
  def index
    @customers = Stripe::Customer.all
  end
end
