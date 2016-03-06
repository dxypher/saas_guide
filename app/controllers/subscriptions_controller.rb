class SubscriptionsController < ApplicationController

  def new

  end

  def create
    # I think this is where you'd add the background job
    # at this point Stripe has not found errors in cc info and has
    # submitted the form in the stripe_payment.js stripeResponseHandler.
    # I can show a notice that a reset email will be sent? Not sure This
    # is needed if they already created an account.

    ap "Inside create in Subscriptions. See params hash"
    ap params
  end

end
