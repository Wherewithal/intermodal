module Intermodal
  module RSpec
    module AuthenticatedRequests
      extend ActiveSupport::Concern

      module ClassMethods
        def expect_unauthorized_access_to_respond_with_401
          context 'with unauthorized access credentials' do
            let(:http_headers) { { 'X-Auth-Token' => '', 'Accept' => 'application/json' } }

            expect_status(401)
          end
        end
      end
    end
  end
end
