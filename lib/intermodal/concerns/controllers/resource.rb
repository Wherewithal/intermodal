module Intermodal
  module Controllers
    module Resource
      extend ActiveSupport::Concern

      included do
        include Intermodal::Controllers::Accountability
        include Intermodal::Controllers::Anonymous
        include Intermodal::Controllers::PaginatedCollection

        respond_to :json

        class_attribute :model, :collection_name, :api

        let(:resource)        { raise 'You must define let(:resource)' }

        let(:model)           { self.class.model || self.class.collection_name.to_s.classify.constantize }
        let(:resource_name)   { collection_name.singularize }
        let(:model_name)      { model.name.underscore.to_sym }

        let(:create_params)   { accepted_params } # Override these if you want different create or update params
        let(:update_params)   { accepted_params }
      end

      # Actions

      # index defined in PaginatedCollection

      def show
        respond_with resource
      end

      def create
        respond_with model.create(create_params)
      end

      def update
        resource.update_attributes(update_params)
        respond_with resource
      end

      def destroy
        resource.destroy
        respond_with resource
      end
    end
  end
end
