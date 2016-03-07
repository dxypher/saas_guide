class SubscriptionsController < ApplicationController

  before_action :authenticate_user!

  def index
    @account = Account.find_by(email: current_user.email)
  end

  def edit
    @account = Account.find(params[:id])
    @plans = Plan.all
  end

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
    current_account = Account.find_by(email: email)
    customer_id = current_account.customer_id
    current_plan = current_account.stripe_plan_id

    if customer_id.nil?
      # Create a Customer
      @customer = Stripe::Customer.create(
      :source => token,
      :plan => plan,
      :email => email
      )
      subscriptions = @customer.subscriptions
      @subscription = subscriptions.data[0]
    else
      @customer = Stripe::Customer.retrieve(customer_id)
      @subscription = create_or_update_subscription(@customer, current_plan, plan)
    end

    # This is a unix timestamp
    current_period_end = @subscription.current_period_end
    # convert to datetime
    active_until = Time.at(current_period_end).to_datetime

    save_account_details( current_account, plan, @customer.id, active_until )

    redirect_to :root, notice: 'Succesfully subscibed!'

  rescue => e
    redirect_to :back, flash: {error: e.message}
  end

  private

  def create_or_update_subscription(customer, current_plan, new_plan)
    subscriptions = customer.subscriptions
    current_subscription = subscriptions.data[0]

    if current_subscription.blank?
      subscription = customer.subscriptions.create(plan: new_plan)
    else
      current_subscription.plan = new_plan
      subscription = current_subscription.save
    end

    subscription
  end

  def save_account_details( current_account, plan, customer_id, active_until )
    # Customer created valid subscription
    # create associated Account record
    current_account.stripe_plan_id = plan
    current_account.customer_id = customer_id
    current_account.active_until = active_until
    current_account.save!
  end

end
