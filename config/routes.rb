Rails.application.routes.draw do
  devise_for :accounts, skip: [ :registrations ]
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  authenticated :account do
    root to: "dashboard#show", as: :authenticated_root
  end

  devise_scope :account do
    unauthenticated :account do
      root to: "devise/sessions#new"
    end
  end

  resource :profile, only: %i[show edit update], controller: "profiles"
  resource :schedule, only: :show, controller: "schedules"
  resources :units, only: %i[index show], controller: "admin/units" do
    resources :grades, except: :index, controller: "admin/grades"
  end

  namespace :admin do
    resources :collaborator_roles, only: %i[index new create]
    resources :people do
      resource :account, controller: "accounts"
    end
    resources :formation_plans
    resources :school_classes
    resources :learning_modules
    resources :units do
      resources :grades, except: :index
    end
    resources :rooms
    resources :lectures

    get "people/:person_id/account/invitation",
        to: "accounts#invitation",
        as: :person_account_invitation,
        defaults: { format: :txt }

    get "people/:id/report_card",
        to: "people#report_card",
        as: :person_report_card,
        defaults: { format: :txt }
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
end
