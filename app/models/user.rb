class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable,
         :async

  validate :email_is_unique, on: :create
  validate :subdomain_is_unique, on: :create

  after_validation :create_tenant
  after_create :create_account

  # def confirmation_required?
  #   false
  # end

  private

  # email should be unique on the Account model
  def email_is_unique
    if email.present?
      if Account.find_by(email: email).present?
        errors.add(:email, " already has an account.")
      end
    end
  end

  def subdomain_is_unique
    if subdomain.present?
      if Account.find_by(subdomain: subdomain).present?
        errors.add(:subdomain, " is already taken.")
      end

      if Apartment::Elevators::Subdomain.excluded_subdomains.include?(subdomain)
        errors.add(:subdomain, ' is not a valid subdomain.')
      end
    end
  end

  def create_account
    account = Account.new(email: email, subdomain: subdomain)
    account.save!
  end

  def create_tenant
    return false if errors.present?
    if self.new_record?
      Apartment::Tenant.create(subdomain)
    end
    Apartment::Tenant.switch!(subdomain)
  end

end
