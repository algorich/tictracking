require 'spec_helper'

describe 'change admin' do
  it 'should have a route change_admin' do
    post('/projects/6/change_admin').should route_to(controller: 'projects',
      action: 'change_admin', id: '6')
  end
end