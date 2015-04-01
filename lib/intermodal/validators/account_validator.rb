require 'active_model/validator'

module Intermodal
  module Validators
    # Validates the associated resource is owned by the same account
    # Examples:
    #
    # validates parent_id, account: true
    # validates parent_id, account: { through: association }
    #
    class AccountValidator < ActiveModel::EachValidator
      def validate_each(record, attribute, value)
        return if value.nil?
        association_name = options[:through] || attribute.to_s.gsub(/_id/, '')
        return if record.send(association_name).account_id == record.account_id
        record.errors[attribute] << message
      end

      def message
        options[:message] || 'must belong to the same account'
      end

    end
  end
end

AccountValidator = Intermodal::Validators::AccountValidator unless defined? AccountValidator
