require 'action_controller/responder'


module Intermodal
  class ResourceResponder < ActionController::Responder
    include Intermodal::Let

    attr_accessor :options

    let(:presenter) { options[:presenter] || controller.send(:presenter) }

    let(:presentation_root)       { options[:presentation_root]  || controller.send(:presentation_root)  }
    let(:presentation_scope)      { options[:presentation_scope] || controller.send(:presentation_scope) }
    let(:always_nest_collections) { options[:always_nest_collections] || controller.send(:always_nest_collections) }

    def initialize(controller, resources, options={})
      super(controller, resources, options)
      @options = options
    end

    # This is the common behavior for "API" requests, like :xml and :json.
    def respond
      return head :status => 404 unless resource
      if get?
        display resource,
          root: presentation_root,
          presenter: presenter,
          scope: presentation_scope,
          always_nest_collections: always_nest_collections

      elsif has_errors?
        display resource.errors,
          root: presentation_root,
          status: :unprocessable_entity,
          presenter: presenter,
          scope: presentation_scope,
          always_nest_collections: always_nest_collections
      elsif put?
        display resource,
          root: presentation_root,
          presenter: presenter,
          scope: presentation_scope,
          always_nest_collections: always_nest_collections
      elsif post?
        display resource,
          root: presentation_root,
          status: :created,
          presenter: presenter,
          scope: presentation_scope,
          always_nest_collections: always_nest_collections
          #:location => api_location # Taken out because it requires some additional URL definitions
      else
        head status: 204
      end
    end

  end
end
