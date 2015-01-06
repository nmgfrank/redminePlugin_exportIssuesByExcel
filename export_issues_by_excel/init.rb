require 'redmine'


require_dependency 'export_issues_by_excel/issues_queries_helper_patch'
require_dependency 'export_issues_by_excel/issues_controller_patch'
require_dependency 'export_issues_by_excel/view_issues_index_bottom_hook_listener'



Redmine::Plugin.register :export_issues_by_excel do
  name 'Export Issues By Excel plugin.  '
  author 'nmgfrank'
  description 'With this plugin, users can export issues in excel format.'
  version '0.0.1'
  url 'http://nmgfrankblog.sinaapp.com'
  author_url 'http://nmgfrankblog.sinaapp.com'
end
