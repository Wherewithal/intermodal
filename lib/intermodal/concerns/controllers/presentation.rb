module Intermodal
  module Controllers
    module Presentation
      extend ActiveSupport::Concern

      included do
        include Intermodal::Let

        let(:api)             { self.class.api }
        let(:model_name)      { raise 'You must define let(:model_name)' }

        let(:presenter)                    { api.presenters[model_name] }
        let(:presentation_root)            { nil }   # Wrap JSON with root key?
        let(:presentation_scope)           { nil }   # Will default to :default scope
        let(:presentation_scope_for_index) { nil }   # Default scope for index
        let(:always_nest_collections)      { false }

        let(:acceptor)        { api.acceptors[model_name] }
        let(:accepted_params) { acceptor.call(params || {}) }
      end

    end
  end
end
