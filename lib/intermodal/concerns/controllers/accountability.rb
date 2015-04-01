require 'intermodal/concerns/controllers/authenticatable'

module Intermodal
  module Controllers

    # This concern builds on top of Intermodal::Controllers::Authenticatable
    # by requiring authentication for all controller actions.
    module Accountability
      extend ActiveSupport::Concern

      included do
        include Intermodal::Controllers::Authenticatable
        before_filter :authentication
      end
    end
  end
end
