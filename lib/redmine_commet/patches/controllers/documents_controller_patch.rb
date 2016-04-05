require_dependency 'documents_controller'
module  RedmineCommet
  module  Patches
    module  Controllers
      module DocumentsControllerPatch
        def self.included(base)
          base.class_eval do
# Creates a new page or updates an existing one
            def create
              @document = @project.documents.build
              @document.safe_attributes = params[:document]
              @document.save_attachments(params[:attachments])
              if @document.save
                render_attachment_warning_if_needed(@document)

                success, msg =  @document.send_data_to_commet
                unless success
                  flash[:error] = msg.html_safe
                end

                flash[:notice] = l(:notice_successful_create)
                redirect_to project_documents_path(@project)
              else
                render :action => 'new'
              end
            end


            def update
              @document.safe_attributes = params[:document]
              if @document.save
                flash[:notice] = l(:notice_successful_update)
                success, msg =  @document.send_data_to_commet
                unless success
                  flash[:error] = msg.html_safe
                end

                redirect_to document_path(@document)
              else
                render :action => 'edit'
              end
            end
          end
        end
      end
    end
  end
end