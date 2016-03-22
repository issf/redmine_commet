require_dependency 'issue'
module  RedmineCommet
  module  Patches
    module IssuePatch
      def self.included(base)
        base.class_eval do
          after_save :send_data_to_commet

          def send_data_to_commet
            webhook = self.project.webhook_settings.where(send_issue: true).first

            if webhook
              require 'net/http'
              url = webhook.url
              path = "#{Setting.plugin_redmine_commet[:redmine_domain]}#{Rails.application.routes.url_helpers.issue_path(self)}"
              uri = URI(url)
              params = {title: self.subject,
                        body: self.description,
                        url: path,
                        createdAt: self.created_on,
                        type: 'Issue'
              }
              res = Net::HTTP.post_form(uri, params)
              puts res.body
            end

          rescue StandardError=> e
            return puts e.message
          end

        end
      end
    end
  end
end
