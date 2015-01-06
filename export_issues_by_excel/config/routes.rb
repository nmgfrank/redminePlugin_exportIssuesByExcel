# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html


match 'projects/:project_id/index_excel/:filename', :controller => 'issues', :action => 'index_excel', :via => [:post,:get]

match 'export_issue_by_excel', :controller => 'issues', :action => 'index_excel', :via => [:post,:get]

