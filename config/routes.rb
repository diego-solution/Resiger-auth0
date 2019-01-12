# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  namespace :api do
    namespace :v1 do

      resources :account, only: [:show, :update] do
        collection do
          post "roles"
          post "change_team"
        end
      end

      resources :locales, only: [] do
        collection do
          get "time_zones"
          get "countries"
        end
      end

      resources :events do
        get "public"
        put "publish"
        put "cancel"

        collection do
          get "grouped"
          post "destroy_all"
        end

        resources :referrers, only: [:create]
        resources :page_contents, only: [:new, :create, :show, :update]

        resources :reports, only: [:index] do
          collection do
            get "download"
          end
        end

        resources :registrants, only: [:index, :update, :create] do
          put "confirm"
        end
      end

      resources :page_layouts, only: [:index, :show, :update, :create, :destroy]

      resources :users, only: [:index, :show, :update, :create] do
        collection do
          post "destroy_all"
        end
        member do
          put "resend_welcome_email"
        end
      end

      resources :team_memberships, only: [:index, :show, :update]

      resources :registration_forms, only: [:index, :new, :show, :update, :create] do
        collection do
          post "destroy_all"
        end
      end

      resources :translations, only: [:index, :create] do
        collection do
          get "original"
        end
      end

      resources :languages, only: [:index, :show]

      resources :groups, only: [:index, :show, :update, :create] do
        collection do
          post "destroy_all"
        end
      end

      resources :teams, only: [:index, :show, :update, :create] do
        collection do
          post "destroy_all"
        end
      end
    end
  end

  get "unsub", to: "home#unsub"
  devise_for :users, skip: [:registrations]

  # below redirects requests to vue js app
  root to: "home#index"
  get '/*path', to: 'home#index', format: false

end
