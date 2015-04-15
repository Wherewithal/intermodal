module Intermodal
  module RSpec
    module PaginatedCollection
      extend ActiveSupport::Concern

      module ClassMethods
        def expect_paginated_resource(options = {}, &customizations)
          # Default behavior for will_paginate
          options[:page] ||= 1
          options[:collection_name]

          context 'when paginating' do
            let(:expected_total_pages) { collection.size/per_page + 1 }
            let(:expected_total_entries) { collection.size }
            let(:collection_element_name) { options[:collection_name] } if options[:collection_name]
            let(:responded_collection_metadata) do
              case format
              when :xml
                body[collection_element_name.to_s]
              else
                body
              end
            end

            instance_eval(&customizations) if customizations

            if options[:empty_collection]
              it 'should have an empty collection' do
                expect(body[collection_element_name.to_s]).to be_empty
              end
            else
              it 'should have a collection' do
                collection
                expect(body[collection_element_name.to_s]).not_to be_empty
              end
            end

            it "should be on page #{options[:page]}" do
              collection
              expect(responded_collection_metadata['page']).to eql(options[:page])
            end

            it 'should have total_pages' do
              collection
              expect(responded_collection_metadata['total_pages']).to eql(expected_total_pages)
            end

            it 'should have total_entries' do
              collection
              expect(responded_collection_metadata['total_entries']).to eql(expected_total_entries)
            end
          end
        end

        # Some version of WillPaginate steps on this
        alias expect_pagination expect_paginated_resource
      end
    end
  end
end
