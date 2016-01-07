class EventsController < ApplicationController
  def index
    @events = Stripe::Event.all
  end

  def show
    @event = Stripe::Event.retrieve(params[:id])
  end
end
