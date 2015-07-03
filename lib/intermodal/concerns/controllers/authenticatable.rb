require 'warden'

module Intermodal
  module Controllers
    # This concern adds an interface for warden, allowing access to
    # the warden user as well as exposing a method to ask warden
    # for authentication.
    module Authenticatable
      extend ActiveSupport::Concern

      included do
        include Intermodal::Let

        let(:account)    { env['warden'].user }
        let(:account_id) { account.id }
      end

      protected

      def authentication
        throw(:warden) unless env['warden'].authenticate?
      end
    end
  end
end
