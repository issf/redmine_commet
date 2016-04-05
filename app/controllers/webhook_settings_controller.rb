class WebhookSettingsController < ApplicationController
  unloadable

  #before_filter :find_project, :except => [:show, :edit, :update, :destroy]
  #before_filter :authorize
  before_filter :find_project, :authorize
  before_filter :find_webhook_setting, :only=> [:edit, :show, :update, :destroy]

  def index
    @webhook_settings = WebhookSetting.where('project_id' => @project.id)
  end

  def new
  end

  def create
    @webhook_setting = WebhookSetting.new(webhook_setting_params)
    @webhook_setting.project_id = @project.id
    @webhook_setting.save
    redirect_to [@project, @webhook_setting]
  end

  def show
  end

  def edit
  end

  def update
    if @webhook_setting.update(webhook_setting_params)
      redirect_to [@project, @webhook_setting]
    else
      render 'edit'
    end
  end

  def destroy
    @webhook_setting.destroy
    redirect_to project_webhook_settings_path
  end

  private
 
  def find_project
    @project = Project.find(params[:project_id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def webhook_setting_params
    params.require(:webhook_setting)
    .permit(:url, :description, :send_issue, :send_wiki, :send_document, :send_file)
  end

  def find_webhook_setting
    @webhook_setting = WebhookSetting.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end
end
