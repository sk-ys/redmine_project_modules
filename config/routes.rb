# frozen_string_literal: true

RedmineApp::Application.routes.draw do
  get 'project_modules', to: 'project_modules#index'
  patch 'project_modules', to: 'project_modules#update'
end
