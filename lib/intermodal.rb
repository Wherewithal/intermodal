require 'intermodal/version'
require 'active_support'
require 'will_paginate'
require 'rlet/functional'

module Intermodal
  # Core
  autoload :API,                'intermodal/api'
  autoload :Configuration,      'intermodal/configuration'

  module DSL
    autoload :Controllers,         'intermodal/dsl/controllers'
    autoload :Mapping,             'intermodal/dsl/mapping'
    autoload :PresentationHelpers, 'intermodal/dsl/presentation_helpers'
  end

  module Mapping
    autoload :Mapper,    'intermodal/mapping/mapper'
    autoload :Presenter, 'intermodal/mapping/presenter'
    autoload :Acceptor,  'intermodal/mapping/acceptor'
  end

  # Controller Templates
  autoload :APIController,             'intermodal/controllers/api_controller'
  autoload :ResourceController,        'intermodal/controllers/resource_controller'
  autoload :NestedResourceController,  'intermodal/controllers/nested_resource_controller'
  autoload :LinkingResourceController, 'intermodal/controllers/linking_resource_controller'

  autoload :ResourceResponder,         'intermodal/responders/resource_responder'
  autoload :LinkingResourceResponder,  'intermodal/responders/linking_resource_responder'

  # Authentication
  # TOOD: Make this more configurable. Not everyone wants X-Auth-Token auth
  module Rack
    autoload :Auth,       'intermodal/rack/auth'
    autoload :Rescue,     'intermodal/rack/rescue'
    autoload :DummyStore, 'intermodal/rack/dummy_store'
  end

  # Authentication currently require two models
  # Credentials are like passwords.
  # Tokens are like cookie sessions. It currently stores against Redis
  module Models
    autoload :Account,          'intermodal/concerns/models/account'
    autoload :AccessCredential, 'intermodal/concerns/models/access_credential'
    autoload :AccessToken,      'intermodal/concerns/models/access_token'
  end

  # Concerns
  autoload :Let, 'intermodal/concerns/let'

  module Models
    autoload :Accountability,    'intermodal/concerns/models/accountability'
    autoload :HasParentResource, 'intermodal/concerns/models/has_parent_resource'
    autoload :ResourceLinking,   'intermodal/concerns/models/resource_linking'
    autoload :Presentation,      'intermodal/concerns/models/presentation'

    autoload :SanitizeHTML,      'intermodal/concerns/models/sanitize_html'
  end

  module Controllers
    autoload :Accountability,      'intermodal/concerns/controllers/accountability'
    autoload :Anonymous,           'intermodal/concerns/controllers/anonymous'
    autoload :Presentation,        'intermodal/concerns/controllers/presentation'
    autoload :PaginatedCollection, 'intermodal/concerns/controllers/paginated_collection'
    autoload :Resource,            'intermodal/concerns/controllers/resource'
    autoload :ResourceLinking,     'intermodal/concerns/controllers/resource_linking'
  end

  module Validators
    autoload :AccountValidator,          'intermodal/validators/account_validator'
    autoload :DifferentAccountValidator, 'intermodal/validators/different_account_validator'
  end

  module Acceptors
    autoload :Resource,      'intermodal/concerns/acceptors/resource'
    autoload :NamedResource, 'intermodal/concerns/acceptors/named_resource'
  end

  module Presenters
    autoload :Resource,      'intermodal/concerns/presenters/resource'
    autoload :NamedResource, 'intermodal/concerns/presenters/named_resource'
  end

  module Rails
    autoload :Rails3Stack,   'intermodal/concerns/rails/rails_3_stack'
    autoload :Rails4Stack,   'intermodal/concerns/rails/rails_4_stack'
    autoload :UseWarden,     'intermodal/concerns/rails/use_warden'
  end

  module Proxies
    autoload :LinkingResources, 'intermodal/proxies/linking_resources'
  end

  # Exceptions
  BadRequest = Class.new(Exception)

  # Extensions
  ActiveSupport.on_load(:after_initialize) do
    # Make sure this loads after Will Paginate loads
    require 'intermodal/proxies/will_paginate'

    ::WillPaginate::Collection.send(:include, Intermodal::Proxies::WillPaginate::Collection)
  end

  Functional = RLet::Functional

  # Rspec Macros
  module RSpec
    # Models
    autoload :Accountability,    'intermodal/rspec/models/accountability'
    autoload :HasParentResource, 'intermodal/rspec/models/has_parent_resource'
    autoload :ResourceLinking,   'intermodal/rspec/models/resource_linking'
    autoload :Sanitization,      'intermodal/rspec/models/sanitization'
    autoload :Validators,        'intermodal/rspec/validators'

    # Requests
    autoload :Rack,                  'intermodal/rspec/requests/rack'
    autoload :HTTP,                  'intermodal/rspec/requests/rfc2616_status_codes'
    autoload :AuthenticatedRequests, 'intermodal/rspec/requests/authenticated_requests'
    autoload :PaginatedCollection,   'intermodal/rspec/requests/paginated_collection'
    autoload :RequestValidations,    'intermodal/rspec/requests/request_validations'
    autoload :Resources,             'intermodal/rspec/requests/resources'
    autoload :LinkedResources,       'intermodal/rspec/requests/linked_resources'
  end
end

require 'intermodal/config'
