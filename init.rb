Redmine::Plugin.register :redmine_commet do
  name 'Redmine Commet plugin'
  author 'Commet development team'
  description 'This is a plugin for Redmine'
  version '0.0.1'
  url 'http://github.com/issf/redmine_commet'
  author_url 'http://github.com/issf'

  project_module :commet do
    permission :manage_commet_webhooks,
               :webhook_settings => [:index, :new, :create,
                                     :show, :edit, :update, :destroy],
               :require => :member
  end

  settings :default=>{
      :redmine_domain=>''
  }, :partial => 'settings/redmine_commet/setting'


  menu :project_menu, :redmine_commet,
       { :controller => 'webhook_settings', :action => 'index' },
       :caption => 'Commet webhooks', :after => :activity, :param => :project_id
end

Rails.application.config.to_prepare do
  Attachment.send(:include, RedmineCommet::Patches::AttachmentPatch)
  Issue.send(:include, RedmineCommet::Patches::IssuePatch)
  Project.send(:include, RedmineCommet::Patches::ProjectPatch)
  WikiContent.send(:include, RedmineCommet::Patches::WikiPatch)
  Document.send(:include, RedmineCommet::Patches::DocumentPatch)
end
