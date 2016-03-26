require_dependency 'issues_controller'
module  RedmineCommet
  module  Patches
    module  Controllers
      module IssuesControllerPatch
        def self.included(base)
          base.class_eval do

            def create
              unless User.current.allowed_to?(:add_issues, @issue.project, :global => true)
                raise ::Unauthorized
              end
              call_hook(:controller_issues_new_before_save, { :params => params, :issue => @issue })
              @issue.save_attachments(params[:attachments] || (params[:issue] && params[:issue][:uploads]))
              if @issue.save
                call_hook(:controller_issues_new_after_save, { :params => params, :issue => @issue})
                success, msg =  @issue.send_data_to_commet
                unless success
                  flash[:error] = msg.html_safe
                end
                respond_to do |format|
                  format.html {
                    render_attachment_warning_if_needed(@issue)
                    flash[:notice] = l(:notice_issue_successful_create, :id => view_context.link_to("##{@issue.id}", issue_path(@issue), :title => @issue.subject))
                    redirect_after_create
                  }
                  format.api  { render :action => 'show', :status => :created, :location => issue_url(@issue) }
                end
                return
              else
                respond_to do |format|
                  format.html {
                    if @issue.project.nil?
                      render_error :status => 422
                    else
                      render :action => 'new'
                    end
                  }
                  format.api  { render_validation_errors(@issue) }
                end
              end
            end

            def save_issue_with_child_records
              Issue.transaction do
                if params[:time_entry] && (params[:time_entry][:hours].present? || params[:time_entry][:comments].present?) && User.current.allowed_to?(:log_time, @issue.project)
                  time_entry = @time_entry || TimeEntry.new
                  time_entry.project = @issue.project
                  time_entry.issue = @issue
                  time_entry.user = User.current
                  time_entry.spent_on = User.current.today
                  time_entry.attributes = params[:time_entry]
                  @issue.time_entries << time_entry
                end

                call_hook(:controller_issues_edit_before_save, { :params => params, :issue => @issue, :time_entry => time_entry, :journal => @issue.current_journal})
                if @issue.save
                  call_hook(:controller_issues_edit_after_save, { :params => params, :issue => @issue, :time_entry => time_entry, :journal => @issue.current_journal})
                  success, msg =  @issue.send_data_to_commet
                  unless success
                    flash[:error] = msg.html_safe
                  end
                else
                  raise ActiveRecord::Rollback
                end
              end
            end



          end
        end
      end
    end
  end
end
