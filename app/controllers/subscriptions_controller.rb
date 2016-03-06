class SubscriptionsController < ApplicationController

  before_action :authenticate_user!

  def new
    @plans = Plan.all
  end

  def create
    # I think this is where you'd add the background job
    # at this point Stripe has not found errors in cc info and has
    # submitted the form in the stripe_payment.js stripeResponseHandler.
    # I can show a notice that a reset email will be sent? Not sure This
    # is needed if they already created an account.

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

    subscriptions = customer.subscriptions
    subscription = subscriptions.data[0]
    # This is a unix timestamp
    current_period_end = subscription.current_period_end
    # convert to datetime
    active_until = Time.at(current_period_end).to_datetime
    # Customer created valid subscription
    # create associated Account record
    account = Account.find_by(email: email)
    account.stripe_plan_id = plan
    account.customer_id = customer.id
    account.active_until = active_until
    account.save!

    redirect_to :root, notice: 'Succesfully subscibed!'

  rescue => e
    redirect_to :new_subscription, flash: {error: e.message}
  end

end
