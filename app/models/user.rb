class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable,
         :async

  validate :email_is_unique, on: :create

  after_create :create_account

  # def confirmation_required?
  #   false
  # end

  private

  # email should be unique on the Account model
  def email_is_unique
    if Account.find_by(email: email).present?
      errors.add(email: " already has an account.")
    end
  end

  def create_account
    account = Account.new(email: email)
    account.save!
  end

end
