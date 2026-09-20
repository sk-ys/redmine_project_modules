# frozen_string_literal: true

require 'redmine'

Redmine::Plugin.register :redmine_project_modules do
  name 'Redmine Project Modules plugin'
  author 'sk-ys'
  description 'Provides a permissions-style management page for project modules.'
  version '0.1.1'
  url 'https://github.com/sk-ys/redmine_project_modules'
  author_url 'https://github.com/sk-ys'

  menu :admin_menu,
       :project_modules,
       { controller: 'project_modules', action: 'index' },
       caption: :label_project_modules,
       html: { class: 'icon icon-projects' },
       icon: 'projects'
end
