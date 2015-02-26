require 'active_model/validator'

module Intermodal
  module Validators
    # Validates the associated resource is owned by a different account
    # Examples:
    #
    # validates parent_id, different_account: true
    # validates parent_id, different_account: { through: association }
    #
    class DifferentAccountValidator < ActiveModel::EachValidator
      def validate_each(record, attribute, value)
        return if value.nil?
        association_name = options[:through] || attribute.to_s.gsub(/_id/, '')
        return if record.send(association_name).account_id != record.account_id
        record.errors[attribute] << message
      end

      def message
        options[:message] || 'must belong to a different account'
      end

    end
  end
end

DifferentAccountValidator = Intermodal::Validators::DifferentAccountValidator unless defined? DifferentAccountValidator
