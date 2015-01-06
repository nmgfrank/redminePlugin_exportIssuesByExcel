
class ViewIssuesIndexBottomHookListener < Redmine::Hook::ViewListener
    def view_issues_index_bottom(context={}) 
        context[:controller].send(:render_to_string, {
            :partial => "hook/view_issues_index_bottom",
            :locals => context  
        })    
    end

end
