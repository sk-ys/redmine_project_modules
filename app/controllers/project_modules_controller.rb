# frozen_string_literal: true

class ProjectModulesController < ApplicationController
  layout 'admin'
  before_action :require_admin

  def index
    load_collections
  end

  def update
    load_collections

    module_matrix = params.fetch(:project_modules, {})

    Project.transaction do
      @projects.each do |project|
        selected_modules = module_matrix.fetch(project.id.to_s, {}).keys
        project.enabled_module_names = selected_modules
        project.save!
      end
    end

    flash[:notice] = l(:notice_successful_update)
    redirect_to action: :index
  rescue ActiveRecord::RecordInvalid
    flash.now[:error] = l(:error_can_not_save_project)
    render action: :index, status: :unprocessable_entity
  end

  private

  def load_collections
    @projects = Project.active.order(:lft).to_a
    @available_modules = Redmine::AccessControl.available_project_modules.sort_by(&:to_s)
  end
end
