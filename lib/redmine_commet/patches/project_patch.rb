require_dependency 'project'
module  RedmineCommet
  module  Patches
    module ProjectPatch
      def self.included(base)
        base.class_eval do
          has_many :webhook_settings
        end
      end
    end
  end
end
