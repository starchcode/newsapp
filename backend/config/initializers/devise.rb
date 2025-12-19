# frozen_string_literal: true

# Devise configuration
# This file will be properly generated when you run: rails generate devise:install
# For now, this is a minimal configuration

Devise.setup do |config|
  # Mailer configuration
  config.mailer_sender = 'please-change-me-at-config-initializers-devise@example.com'

  # ORM configuration
  require 'devise/orm/active_record'

  # Configuration for authentication
  config.case_insensitive_keys = [:email]
  config.strip_whitespace_keys = [:email]
  config.skip_session_storage = [:http_auth]

  # Password configuration
  config.stretches = Rails.env.test? ? 1 : 12

  # Email confirmation disabled (as requested)
  config.reconfirmable = false

  # Password length
  config.password_length = 6..128
  config.email_regexp = /\A[^@\s]+@[^@\s]+\z/

  # Remember me configuration
  config.expire_all_remember_me_on_sign_out = true

  # Sign out configuration
  config.sign_out_via = :delete
end
