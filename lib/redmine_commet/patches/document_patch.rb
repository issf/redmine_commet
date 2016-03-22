require_dependency 'document'
module  RedmineCommet
  module  Patches
    module DocumentPatch
      def self.included(base)
        base.class_eval do
          after_save :send_data_to_commet

          def send_data_to_commet
            webhook = self.project.webhook_settings.where(send_document: true).first

            if webhook
              require 'net/http'
              url = webhook.url
              uri = URI(url)
              path = "#{Setting.plugin_redmine_commet[:redmine_domain]}#{Rails.application.routes.url_helpers.document_path(self)}"
              params= {title: self.title,
                       body: self.description,
                       url: path ,
                       createdAt: self.created_on,
                       type: 'Document'
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
