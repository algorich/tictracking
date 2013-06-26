class MembershipsController < ApplicationController
  def destroy
    @membership = Membership.find(params[:id])
    @membership.destroy
    @project = @membership.project

    params[:message] = { type: 'success', text: 'User was removed from this project' }
    render 'projects/update_team'
  end
end