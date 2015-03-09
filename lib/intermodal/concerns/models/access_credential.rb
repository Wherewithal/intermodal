require 'active_model/secure_password'

module Intermodal
  module Models
    module AccessCredential
      extend ActiveSupport::Concern

      included do
        include Intermodal::Models::Accountability
        include ActiveModel::SecurePassword

        has_secure_password

        # Validations
        validates_uniqueness_of :identity

        # Associations
        belongs_to :account

        def self.authenticate!(identity, key)
          access = self.find_by(identity: identity).try(:authenticate, key)
          return false unless access
          access.account
        end
      end
    end
  end
end
