class WebhookSettingsController < ApplicationController
  unloadable

  before_filter :find_project, :authorize

  def index
    @webhook_settings = WebhookSetting.where('project_id' => @project.id)
  end

  def new
  end

  def create
  end

  def show
    webhook_setting = WebhookSetting.find(params[:id])
  end

  def edit
    webhook_setting = WebhookSetting.find(params[:id])
  end

  def update
  end

  def destroy
  end

  private
 
  def find_project
    @project = Project.find(params[:project_id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end
end
