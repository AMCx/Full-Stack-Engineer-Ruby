Rails.application.routes.draw do

  root 'comics#index'
  resources :comics, only: :index

  namespace :api, defaults: {format: :json} do
    scope module: :v1, constraints: ApiConstraints.new(version: 1, default: :true) do

      resources :characters, only: :index
      resources :favorites, only: [:create, :destroy]

    end
  end

end
