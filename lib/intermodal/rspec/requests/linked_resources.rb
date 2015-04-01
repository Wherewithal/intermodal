module Intermodal
  module RSpec
    module LinkedResources
      extend ActiveSupport::Concern

      included do
        include Intermodal::RSpec::Resources
      end

      module ClassMethods
        def link_resource(parent_resource, options = {}, &blk)
          metadata[:parent_resource] = options[:parent_resource] = parent_resource
          metadata[:target_resources] = options[:to]
          metadata[:linking_resource_model] = options[:with]

          _target_resources = options[:to]

          resource_options = {
            :namespace => options[:namespace]
          }
          resources [metadata[:parent_resource].to_s.pluralize, metadata[:target_resources]], resource_options do
            let(:model) { options[:with] }
            let(:model_parents) { [ send(options[:parent_resource]) ] }
            let(:unlinked_targets) { raise "Override :unlinked_targets with let()" }
            let(:target_resources) { _target_resources }
            let(:collection_element_name) { "#{target_resources.to_s.singularize}_ids" }
            let(:paginated_collection) { collection }
            let(:resource_element_name) { parent_resource }
            let(:presentation_root) { options[:parent_resource] }
            let(:collection_proxy) do
              Intermodal::Proxies::LinkingResources.new presentation_root,
                :to => target_resources,
                :with => collection,
                :parent_id => model_parents.first.id
            end
            let(:presented_collection) { parser.decode(collection_proxy.send("to_#{format}")) }
            instance_eval(&blk)
          end
        end

        def expect_crud_for_linked_resource
          expect_index :skip_pagination_examples => true do
            it 'should include the parent id' do
              collection.should_not be_empty
              body[resource_element_name.to_s]['id'].should eql(model_parents.first.id)
            end
          end

          expect_list_replace
          expect_list_append
          expect_list_remove
        end

        def expect_list_replace(&blk)
          _metadata = metadata
          request :post, metadata[:collection_url] do
            let(:request_url) { collection_url }
            let(:replacement_target_ids) { unlinked_targets.map(&:id) }
            let(:request_payload) { { collection_element_name => replacement_target_ids } }
            let(:updated_target_ids) { model.by_parent(model_parent).to_target_ids }

            instance_eval(&blk) if blk

            expect_status(201)
            expect_content_type(metadata[:mime_type], metadata[:encoding])

            with_malformed_data_should_respond_with_400
            with_nil_target_ids_should_respond_with_422
            expect_unauthorized_access_to_respond_with_401

            context 'with empty payload' do
              let(:request_payload) { { collection_element_name => [] } }

              expect_status(201)
              expect_content_type(metadata[:mime_type], metadata[:encoding])

              it 'should reset resource linking' do
                response.should_not be_empty
                updated_target_ids.should be_empty
              end
            end

            it "should link #{metadata[:target_resources]} to #{metadata[:parent_resource]}" do
              model_collection.should_not be_empty
              response.should_not be_empty
              replacement_target_ids.each do |replacement_target_id|
                updated_target_ids.should include(replacement_target_id)
              end
            end

            it "should delete original linked #{metadata[:target_resources]}" do
              model_collection.should_not be_empty
              response.should_not be_empty
              model_collection.each do |original_target_id|
                updated_target_ids.should_not include(original_target_id)
              end
            end
          end
        end

        def expect_list_append(&blk)
          _metadata = metadata
          request :put, metadata[:collection_url] do
            instance_eval(&blk) if blk
            let(:request_url) { collection_url }
            let(:additional_target_ids) { unlinked_targets.map(&:id) }
            let(:request_payload) { { collection_element_name => additional_target_ids } }
            let(:updated_target_ids) { model.by_parent(model_parent).to_target_ids }

            expect_status(200)
            expect_content_type(metadata[:mime_type], metadata[:encoding])

            it 'should link additional targets to manufacturer' do
              model_collection.should_not be_empty
              response.should_not be_empty
              additional_target_ids.each do |additional_target_id|
                updated_target_ids.should include(additional_target_id)
              end
            end

            it 'should append to, but not delete original linked targets' do
              model_collection.should_not be_empty
              response.should_not be_empty
              model_collection.each do |original_target_id|
                updated_target_ids.should include(original_target_id)
              end
            end

            with_malformed_data_should_respond_with_400
            with_nil_target_ids_should_respond_with_422
            expect_unauthorized_access_to_respond_with_401
          end
        end

        def expect_list_remove(&blk)
          _metadata = metadata
          request :delete, metadata[:collection_url] do
            instance_eval(&blk) if blk
            let(:request_url) { collection_url }
            let(:deleted_target_ids) { model_collection[0..1] }
            let(:remaining_target_ids) { model_collection - deleted_target_ids }
            let(:request_payload) { { collection_element_name => deleted_target_ids } }
            let(:updated_target_ids) { model.by_parent(model_parent).to_target_ids }

            expect_status(200)
            expect_content_type(metadata[:mime_type], metadata[:encoding])

            it 'should delete linked targets' do
              deleted_target_ids.should_not be_empty
              response.should_not be_empty
              deleted_target_ids.each do |deleted_target_id|
                updated_target_ids.should_not include(deleted_target_id)
              end
            end

            it 'should keep remaining targets' do
              deleted_target_ids.should_not be_empty
              response.should_not be_empty
              remaining_target_ids.each do |remaining_target_id|
                updated_target_ids.should include(remaining_target_id)
              end
            end

            with_malformed_data_should_respond_with_400
            with_nil_target_ids_should_respond_with_422
            expect_unauthorized_access_to_respond_with_401
          end
        end

        def with_nil_target_ids_should_respond_with_422
          context 'without nil ids ' do
            let(:request_payload) { { collection_element_name => nil } }
            expect_status(422)
          end
        end

      end
    end
  end
end
