module Intermodal
  module RSpec
    module RequestValidations
      extend ActiveSupport::Concern

      module ClassMethods
        # This macro expects the following to be defined:
        # let(:valid_payload) { request_payload that would succeed }
        #
        # You then pass a override hash and the expected response code,
        # usually a 400 Bad Request or 422 Unprocessible Entity
        #
        # In overrides, if you pass a callable object such as a lambda or a proc,
        # then it will be called at test time before merging into the request payload.
        #
        # Example:
        #
        # overrides: { apple: -> { tree.apples.sample } }
        def expect_request_invalid(message, opts={}, &additional_examples)
          _status     = opts[:status] || 422
          _overrides  = opts[:overrides] or raise 'Must pass overrides: parameter'

          context "when #{message}" do
            let(:request_payload) { attributes.merge(overrides) }
            let(:overrides)       { Hash[_overrides.map(&eval_hash)] }
            let(:eval_hash)       { ->(x) { [x[0].to_s, maybe_call.(x[1]) ] } }
            let(:maybe_call)      { ->(x) { x.respond_to?(:call) ? x.call : x } }

            expect_status _status
            instance_eval(&additional_examples) if additional_examples
          end
        end
      end
    end
  end
end
