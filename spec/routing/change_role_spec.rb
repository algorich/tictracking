require 'spec_helper'

describe 'change role' do
  it 'should have a route change_role' do
    post('/projects/6/change_role').should route_to(controller: 'projects',
      action: 'change_role', id: '6')
  end
end