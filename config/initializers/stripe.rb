Stripe.api_key = Rails.application.secrets.stripe_key

require 'extensions/stripe'
Stripe.include Extensions::Stripe