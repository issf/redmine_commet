require_dependency 'wiki_content'
module  RedmineCommet
  module  Patches
    module WikiPatch
      def self.included(base)
        base.class_eval do
          after_save :send_data_to_commet

          def send_data_to_commet
            webhook = self.project.webhook_settings.where(send_wiki: true).first

            if webhook
              require 'net/http'
              url = webhook.url
              path = "#{Setting.plugin_redmine_commet[:redmine_domain]}#{Rails.application.routes.url_helpers.wiki_path(self.page.wiki)}"

              uri = URI(url)
              params = {title: self.page.wiki.start_page,
                        body: self.text,
                        url: path,
                        createdAt: self.updated_on,
                        type: 'Wiki'
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
