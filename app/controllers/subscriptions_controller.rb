class SubscriptionsController < ApplicationController

  def new
    @plans = Plan.all
  end

  def create
    # I think this is where you'd add the background job
    # at this point Stripe has not found errors in cc info and has
    # submitted the form in the stripe_payment.js stripeResponseHandler.
    # I can show a notice that a reset email will be sent? Not sure This
    # is needed if they already created an account.

    ap "Inside create in Subscriptions. See params hash"
    ap params

    # Get the credit card details submitted by the form
    token = params[:stripeToken]
    plan  = params[:plan][:stripe_id]
    email = current_user.email #assumes user is logged in to subscribe

    # Create a Customer
    customer = Stripe::Customer.create(
      :source => token,
      :plan => plan,
      :email => email
    )

  rescue => e
    redirect_to :new_subscription, flash: {error: e.message}
  end

end
