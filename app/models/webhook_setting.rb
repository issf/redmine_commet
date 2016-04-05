class WebhookSetting < ActiveRecord::Base
  unloadable
  belongs_to :project

  validate :check_url

  def check_url
    require 'uri'
    unless url =~ URI::regexp
      errors.add(:url, 'Not valid')
    end
  end
end
