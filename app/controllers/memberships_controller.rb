class MembershipsController < ApplicationController
  def destroy
    @membership = Membership.find(params[:id])
    @project = @membership.project

    if @membership.can_toggle_admin?
      @membership.destroy
      params[:message] = { type: 'success', text: 'User was removed from this project' }
    else
      params[:message] = { type: 'error', text: 'Project should have at least one admin!' }
    end
    render 'projects/update_team'
  end
end