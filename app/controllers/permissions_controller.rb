class PermissionsController < ApplicationController
  before_action :find_role, only: %i(edit update)

  def edit
    
  end

  private

  def find_role
    @role = Role.find(params[:id])
  end
end
