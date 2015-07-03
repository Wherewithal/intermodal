module Intermodal
  class ResourceController < Intermodal::APIController
    include Intermodal::Controllers::Resource

    private
    let(:collection)    { model.get(:all, account: account) }
    let(:resource)      { model.get(resource_id, account: account) }
    let(:resource_id)   { params[:id] }
    let(:create_params) { accepted_params.merge(account_id: account_id) }
    let(:update_params) { accepted_params }
  end
end
