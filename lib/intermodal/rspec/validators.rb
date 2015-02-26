require 'active_support/concern'

module Intermodal
  module RSpec
    module Validators
      extend ActiveSupport::Concern

      included do
        # Make sure to define:
        #   let(:resource)                    # resource to be tested
        #   let(:associated_resource)         # association and resource both owned by same account
        #   let(:invalid_associated_resource) # association and resource owned by different account
        #
        # Optional
        #   let(:attribute) # Attribute being validated
        #   let(:message)   # Error message
        #
        def self.validates_same_account(association, &additional_examples)
          context "validates #{association} is owned by same account" do
            let(:attribute) { association }
            let(:message)   { 'must belong to the same account' }

            context 'when association belongs to same account' do
              it 'should be_valid' do
                expect(resource.account_id).to eql(associated_resource.account_id)
                expect(resource).to be_valid
                expect(resource.errors).not_to have_key(attribute)
              end
            end

            context 'when association belongs to a different account' do
              before(:each) { resource.send("#{association}=", invalid_associated_resource) }

              it 'should not be valid and report the error' do
                expect(resource.account_id).not_to eql(invalid_associated_resource.account_id)
                expect(resource).not_to be_valid
                expect(resource.errors).to have_key(attribute)
                expect(resource.errors[attribute]).to include(message)
              end
            end

            instance_eval(&additional_examples) if additional_examples
          end
        end

        # Make sure to define:
        #   let(:resource)                    # resource to be tested
        #   let(:associated_resource)         # association and resource owned by different accounts
        #   let(:invalid_associated_resource) # association and resource both owned by same account
        #
        # Optional
        #   let(:attribute) # Attribute being validated
        #   let(:message)   # Error message
        #
        def self.validates_different_account(association, &additional_examples)
          context "validates #{association} is owned by a different account" do
            let(:attribute) { association }
            let(:message)   { 'must belong to a different account' }

            context 'when association belongs to same account' do
              before(:each) { resource.send("#{association}=", invalid_associated_resource) }

              it 'should not be valid' do
                expect(resource.account_id).to eql(invalid_associated_resource.account_id)
                expect(resource).not_to be_valid
                expect(resource.errors).to have_key(attribute)
                expect(resource.errors[attribute]).to include(message)
              end
            end

            context 'when association belongs to a different account' do

              it 'should not be valid and report the error' do
                expect(resource.account_id).not_to eql(associated_resource.account_id)
                expect(resource).to be_valid
                expect(resource.errors).not_to have_key(attribute)
              end
            end

            instance_eval(&additional_examples) if additional_examples
          end
        end
      end
    end
  end
end
