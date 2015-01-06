require 'redmine/pagination'
require_dependency 'issues_controller'


module IssuesControllerPatch
    def self.included(base)
        base.send(:include, InstanceMethods)
        base.class_eval do
          before_filter :authorize, :except => [:index,:index_excel]
          accept_rss_auth :index, :show, :index_excel
          accept_api_auth :index, :show, :create, :update, :destroy, :index_excel                        
        end
    end

    module InstanceMethods
            
          def index_excel
            @project = Project.find(params[:project_id]) if params[:project_id]
            retrieve_query
            sort_init(@query.sort_criteria.empty? ? [['id', 'desc']] : @query.sort_criteria)
            sort_update(@query.sortable_columns)
            @query.sort_criteria = sort_criteria.to_a

            if @query.valid?
              @limit = Setting.issues_export_limit.to_i

              @issue_count = @query.issue_count
              #@issue_pages = Paginator.new @issue_count, @limit, params['page']
              #@offset ||= @issue_pages.offset
              @offset = 0
              @issues = @query.issues(:include => [:assigned_to, :tracker, :priority, :category, :fixed_version],
                                      :order => sort_clause,
                                      :offset => @offset,
                                      :limit => @limit)
              @issue_count_by_group = @query.issue_count_by_group
              
              @items = []
              
              status_hash = {}
              IssueStatus.all.each do |s|
                status_hash[s.id.to_s] = s.name
              end
              
              status_names = []

              @issues.each do |issue|
                  item = {}
                  item[:issue] = issue
                  item[:status_change] = {}
                  
                  
                  if !params[:status_change].blank?
                      i_ctime = issue.created_on
                      i_status_id = issue.status_id
                      i_status_name = status_hash[i_status_id.to_s]
                      
                      idx = 0
                      if issue.journals.length > 0
                          
                          issue.journals.each do |journal|
                              j_ctime = journal.created_on
                              journal.details.each do |detail|
                                  if detail.prop_key == "status_id"
                                    idx += 1  
                                    status_name = status_hash[detail.value.to_s]
                                    old_status_name = status_hash[detail.old_value.to_s]
                                    
                                    if !status_names.include? status_name
                                        status_names.push(status_name)
                                    end
                                    if !status_names.include? old_status_name
                                        status_names.push(old_status_name)
                                    end
                                    
                                    if idx == 1
                                        item[:status_change][old_status_name] = i_ctime
                                    end

                                    if !item[:status_change].has_key? status_name
                                        item[:status_change][status_name] = j_ctime
                                    else
                                        if j_ctime > item[:status_change][status_name]
                                            item[:status_change][status_name] = j_ctime
                                        end
                                    end 
                                            
                                  end
                              end 
                          end
                      end
                      
                      if idx == 0
                          if !status_names.include? i_status_name
                            status_names.push(i_status_name)
                          end
                          item[:status_change][i_status_name] = i_ctime 
                      end                     
                      
                      
                      
                  end
                  @items.push(item)
              end

              send_data(query_to_xlsx(@items, @query, status_names,params), :type => "text/excel;charset=utf-8; header=present",   :filename => 'issues.xls') 
            else
              render(:nothing => true)
            end
          rescue ActiveRecord::RecordNotFound
            render_404
          end
    end
end

IssuesController.send(:include, IssuesControllerPatch)
