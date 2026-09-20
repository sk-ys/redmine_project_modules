# frozen_string_literal: true

class ProjectModulesController < ApplicationController
  layout 'admin'
  before_action :require_admin
  protect_from_forgery with: :exception

  def index
    load_collections
  end

  def update
    load_collections

    module_matrix = params.fetch(:project_modules, {})

    Project.transaction do
      @projects.each do |project|
        selected_modules = filtered_modules_for(project.id, module_matrix, @available_module_names)
        preserved_modules = project.enabled_module_names - @available_module_names
        project.enabled_module_names = selected_modules | preserved_modules
        project.save!
      end
    end

    flash[:notice] = l(:notice_successful_update_project_modules_page)
    redirect_to action: :index, page: params[:page]
  rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotSaved, ActiveRecord::StatementInvalid
    flash.now[:error] = l(:error_can_not_save_project)
    render action: :index, status: :unprocessable_entity
  end

  private

  def load_collections
    scope = Project.active.order(:lft)
    @project_count = scope.count
    @limit = per_page_option
    @project_pages = Redmine::Pagination::Paginator.new(@project_count, @limit, params[:page])
    @offset = @project_pages.offset
    @projects = scope.offset(@offset).limit(@limit).to_a
    available_modules = if Redmine::AccessControl.respond_to?(:available_project_modules)
                          Redmine::AccessControl.available_project_modules
                        else
                          Redmine::AccessControl.permissions.map(&:project_module).compact.uniq
                        end
    @available_modules = available_modules
    @available_module_names = @available_modules.map(&:to_s)
  end

  def filtered_modules_for(project_id, module_matrix, available_module_names)
    module_matrix.fetch(project_id.to_s, {}).keys & available_module_names
  end
end
