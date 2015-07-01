module Intermodal
  module RSpec
    # All Intermodal controllers require models that belongs to an
    # account object and responds to #get. This allows the controllers
    # to fetch records authorized by the account.
    #
    # This RSpec macro tests these assumptions.
    #
    # Usage:
    #
    # class Resource < ActiveRecord::Base
    #   include Intermodal::Models::Accountability
    # end
    #
    # describe Resource do
    #   include Intermodal::RSpec::Accountability
    #
    #   concerned_with_accountability
    # end
    #
    # It works with Remarkable. It might work with Shoulda
    #
    # If you don't want to use either, you can try
    #
    # describe Resource do
    #   include Intermodal::RSpec::Accountability
    #
    #   implements_get_interface
    # end
    #
    module Accountability
      extend ActiveSupport::Concern

      module ClassMethods
        def concerned_with_accountability(&blk)
          instance_eval(&blk) if blk

          context 'when concerned with accountability' do
            let(:model) { described_class }
            it { is_expected.to belong_to :account }
            it { is_expected.to validate_presence_of :account_id }
            it { expect(model).to respond_to :by_account_id }
            it { expect(model).to respond_to :by_account }

            implements_get_interface
          end
        end

        def implements_get_interface(&blk)
          describe '.get' do
            let(:model) { described_class }
            let(:different_account) { Account.make! }

            it { expect(model).to respond_to :get }

            context ':all' do
              context 'when unscoped to account' do
                let(:collection) { model.get(:all) }
                it 'should find all resources' do
                  expect(collection).to include(resource)
                  expect(collection.size).to eql(1)
                end
              end

              context 'when scoped to account' do
                let(:collection) { model.get(:all, account: account) }
                it 'should find all resources' do
                  expect(collection).to include(resource)
                  expect(collection.size).to eql(1)
                end
              end
            end

            context 'by id' do
              subject { described_class.get(resource.id) }
              it 'should find resource by id' do
                is_expected.to eql(resource)
              end

              it 'should return a writeable resource' do
                is_expected.not_to be_readonly
              end
            end

            context 'by account' do
              it 'should find resource scoped to account' do
                expect(model.get(resource.id, account: account)).to eql(resource)
              end

              it 'should find resource scoped to account id' do
                expect(model.get(resource.id, account_id: account.id)).to eql(resource)
              end

              it 'should find a writeable resource scoped to account id' do
                expect(model.get(resource.id, account_id: account.id)).not_to be_readonly
              end

              it 'should not find resource scoped to a different account' do
                expect { model.get(resource.id, account: different_account) }.to raise_error(ActiveRecord::RecordNotFound)
              end

              it 'should not find resource scoped to a different account id ' do
                expect { model.get(resource.id, account_id: different_account.id) }.to raise_error(ActiveRecord::RecordNotFound)
              end
            end

            instance_eval(&blk) if blk
          end
        end # implements_get_interface
      end # ClassMethods

    end
  end
end

