module Intermodal
  module Rails
    module Rails4Stack
      extend ActiveSupport::Concern

      # Delete extraneous middleware

      included do
        # Intermodal currently does not support concurrency
        config.allow_concurrency = false
        config.middleware.delete 'Rack::Lock'             # Run this in a multi-process server, not multithreaded

        config.middleware.delete 'ActiveRecord::QueryCache'
        config.middleware.delete 'ActionDispatch::Cookies'
        config.middleware.delete 'ActionDispatch::Session::CookieStore'
        config.middleware.delete 'ActionDispatch::Flash'

        # Use our own parsing code and responses, or drop this after Intermodal::Rack::Rescue
        config.middleware.delete 'ActionDispatch::ParamsParser'
      end
    end
  end
end
