# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
ProjectSignups::Application.initialize!


ActionMailer::Base.delivery_method = :smtp
ActionMailer::Base.smtp_settings = {
  :user_name      => ENV['SENDGRID_USERNAME'],
  :password       => ENV['SENDGRID_PASSWORD'],
  :domain         => ENV['SENDGRID_DOMAIN'],
  :address => "smtp.sendgrid.net",
  :port => 587,
  :authentication => :plain,
  :enable_starttls_auto => true
}

# :user_name => "tkoc8qtb",
# :password => "app8956819@heroku.com",
# :domain => "heroku.com",
