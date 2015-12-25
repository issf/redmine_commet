# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html
Rails.application.routes.draw do
  resources :webhook_settings, :only => [:show, :edit, :update, :destroy]

  resources :projects do
    resources :webhook_settings, :except => [:show, :edit, :update, :destroy]
  end
end
