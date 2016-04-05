require_dependency 'wiki_content'
module  RedmineCommet
  module  Patches
    module WikiPatch
      def self.included(base)
        base.class_eval do
          def send_data_to_commet
            webhook = self.project.webhook_settings.where(send_wiki: true).first
            if webhook
              require 'net/http'
              url = webhook.url
              wiki = self.page.wiki
              path = "#{Setting.protocol}://#{Setting.host_name}#{Rails.application.routes.url_helpers.project_wiki_page_path(wiki.project, self.page.title)}"
              uri = URI(url)
              params = {documentId: path,
                        title: self.page.wiki.start_page,
                        body: self.text,
                        url: path,
                        createdAt: self.updated_on.iso8601,
                        type: 'Wiki'
              }
              http = Net::HTTP.new(uri.host, uri.port)
              res = http.post(uri.path, params.to_json, {'Content-Type' =>'application/json'})
              if res.code == "200"
                return [true, res.code]
              else
                return [false, "Failed to send the wiki page to the webhook: #{res.code}: #{res.msg}\n#{res.body}"]
              end
            end
            return [true, '']
          rescue StandardError=> e
            return [false, e.message]
          end

        end
      end
    end
  end
end
