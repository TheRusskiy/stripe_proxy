class CustomersController < ApplicationController
  def index
    @customers = Stripe::Customer.all
  end

  def show
    @customer = Stripe::Customer.retrieve(params[:id])
  end
end
