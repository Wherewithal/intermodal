module Intermodal
  module Controllers
    module PaginatedCollection
      extend ActiveSupport::Concern

      included do
        let(:collection)      { raise 'You must define collection' }
        let(:collection_name) { self.class.collection_name.to_s } # TODO: This might already be defined in Rails 3.x
        let(:presented_collection) { collection.paginate :page => params[:page], :per_page => per_page }

        let(:per_page) do
          if params[:per_page]
            params[:per_page].to_i <= api.max_per_page ? params[:per_page] : api.max_per_page
          else
            api.default_per_page
          end
        end
      end

      def index
        respond_with presented_collection, :presentation_root => collection_name, :presentation_scope => presentation_scope_for_index
      end
    end
  end
end
