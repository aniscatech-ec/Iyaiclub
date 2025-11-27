Rails.application.routes.draw do
  # get "policy_and_privacy/index"
  # get "terms_and_conditions/index"
  get "/terms_and_conditions", to: "terms_and_conditions#index"
  get "/policy_and_privacy", to: "policy_and_privacy#index"
  resources :menu_categories do
    resources :menu_items
  end # CRUD global
  resources :restaurants do
    member do
      get :menu_categories_selector
      patch :update_menu_categories
    end
    collection do
      get :search_results
    end
    # resources :menu_categories do
    #   resources :menu_items do
    #     resources :menu_options
    #   end
    # end
  end
  # resources :countries do
  #   resources :provinces do
  #     resources :cities, only: [:index, :new, :create]
  #   end
  # end
  # # resources :provinces
  # resources :provinces do
  #   resources :cities, only: [:index, :new, :create]
  # end
  # resources :cities do
  #   get :autocomplete, on: :collection
  # end
  # CRUD de países y sus provincias
  resources :hotels do
    member do
      delete :remove_image
    end
    collection do
      get :search_results
    end
    resources :units do
      resources :reservations
      resources :unit_availabilities do
        post :toggle, on: :collection
      end
    end

  end

  resources :countries do
    resources :provinces, only: [:index, :new, :create]
    resources :cities, only: :index
  end

  # CRUD de provincias y sus ciudades
  resources :provinces do
    resources :cities, only: [:index, :new, :create]
  end

  # Endpoint global de autocomplete para ciudades
  resources :cities do
    get :autocomplete, on: :collection
  end


  resources :plans
  resources :plan_prices
  resources :subscriptions do
    resources :payment_receipts do
      member do
        patch :approve
        patch :reject
      end
    end
    member do
      patch :approve
      patch :cancel
    end
    collection do
      get :establishments_for_user
      get :selector
      get :index_establishments # Para afiliados → mostrar sus establecimientos
      get :establishment_plans
      get :tourist_plans
    end
  end

  resources :amenities
  get "home/home"

  resources :establishments do
    collection do
      get :choose_type # pantalla de tarjetas
      get :select_affiliate
      post :create_type # crear el establecimiento según el tipo
      get :search_results
    end
    resources :establishment_steps
    member do
      get :dashboard # /establishments/:id/dashboard
    end
    resources :galleries do
      resources :gallery_images do
        member do
          patch :set_cover   # ← agrega esta línea
        end
      end
    end
  end
  namespace :turista do
    get "dashboard/index"
  end
  namespace :afiliado do
    get "dashboard/index"
  end
  devise_for :users

  # get "home/index"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  # get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
  root "home#index"
  # authenticated :user do
  #   root to: "dashboard#index", as: :authenticated_root
  # end
  #
  # unauthenticated do
  #   root to: "home#index", as: :unauthenticated_root
  # end
  namespace :admin do
    get "dashboard/index"
    resources :users do
      get :establishments, on: :member
      collection do
        get :users_by_role
      end
    end
  end

  namespace :admin do
    get "dashboard/index"

    resources :users do
      get :establishments, on: :member
      collection do
        get :users_by_role
      end

      # 👇 Aquí anidamos las suscripciones
      # resources :subscriptions, only: [:index, :new, :create]
    end
  end

end
