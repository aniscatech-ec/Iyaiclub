Rails.application.routes.draw do
  resources :restaurants
  resources :transports
  resources :temporary_lodgings
  resources :getaways, only: [:index, :show] do
    resources :bookings, only: [:index, :new, :create, :show, :update, :destroy]
  end
  
  resources :experiences, only: [] do
    resources :bookings, only: [:index, :new, :create, :show, :update, :destroy]
  end

  resources :lodgings, only: [] do
    resources :bookings, only: [:index, :new, :create, :show, :update, :destroy]
  end

  resources :bookings, only: [:index]

  # API para ubicaciones dinámicas
  namespace :locations do
    get 'provinces/:country_id', to: 'locations#provinces'
    get 'cities/:province_id', to: 'locations#cities'
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
    resources :bookings, only: [:index, :new, :create, :show, :update, :destroy]
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


  # PayPhone payment gateway
  scope :payphone, controller: 'payphone', as: :payphone do
    post :checkout, action: :checkout
    get  :callback, action: :callback
    get  :cancel,   action: :cancel
  end

  resources :plan_prices
  resources :subscriptions do
    member do
      patch :approve
      patch :cancel
    end
    collection do
      get  :establishments_for_user
      get  :selector
      get  :index_establishments
      get  :establishment_plans
      get  :tourist_plans
      post :reservar_transferencia
    end
  end

  resources :amenities
  get "home/home"

  # Solicitudes personalizadas (Reserva Personalizada Iyaiclub)
  # Rutas públicas: sólo new/create (requieren login en el controller).
  resources :custom_requests, only: [:new, :create]

  resources :establishments do
    collection do
      get :choose_type  # pantalla de tarjetas
      get :select_affiliate
      post :create_type # crear el establecimiento según el tipo
    end
    resources :establishment_steps
    resources :getaways, shallow: true
    resources :lodgings, shallow: true
    resources :experiences, shallow: true
    member do
      get :dashboard  # /establishments/:id/dashboard
    end
  end
  namespace :turista do
    resources :dashboard, only: [:index]
    resources :bookings, only: [:index, :show]
    resources :getaways, only: [] do
      resources :benefit_requests, only: [:new, :create], controller: "benefit_requests"
    end
    resources :hotels, only: [] do
      resources :benefit_requests, only: [:new, :create], controller: "benefit_requests"
    end
    resources :lodgings, only: [] do
      resources :benefit_requests, only: [:new, :create], controller: "benefit_requests"
    end
    resources :visits, only: [:index]
    resources :points, only: [:index]
    resources :rewards, only: [:index] do
      member do
        post :redeem
      end
    end
    resources :redemptions, only: [:index]
    resources :memberships, only: [:index] do
      member do
        patch :cancel
        patch :reactivate
      end
    end
    resources :custom_requests, only: [:index, :show]
    resources :tickets, only: [:index, :show] do
      member do
        get :download
        patch :mark_as_used
        get :check_status
      end
    end
    resources :events, only: [:index, :show] do
      resources :tickets, only: [] do
        collection do
          get :new_free
          post :create_free
          get :new_purchase
          post :create_purchase
          get :new_transfer
          post :create_transfer
          get :transfer_status
        end
      end
    end
  end
  namespace :vendedor do
    resources :dashboard, only: [:index]
    resources :events, only: [] do
      resources :tickets, only: [:index] do
        member do
          patch :acreditar
          patch :rechazar
        end
        collection do
          patch :bulk_acreditar
          patch :bulk_rechazar
        end
      end
    end
    resources :memberships, only: [:index, :destroy] do
      member do
        patch :acreditar
        patch :rechazar
        patch :suspender
        patch :reactivar
      end
      collection do
        patch :bulk_acreditar
        patch :bulk_rechazar
      end
    end
  end
  namespace :afiliado do
    get "dashboard/index"
  end
  devise_for :users, controllers: {
    confirmations: 'users/confirmations',
    registrations: 'users/registrations'
  }, sign_out_via: [:get, :delete]

  # Vista informativa mostrada tras el registro para indicar al usuario
  # que debe revisar su correo y confirmar la cuenta
  get 'users/confirmation_pending', to: 'users/registrations#confirmation_pending', as: :users_confirmation_pending

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

  resources :events, only: [:index, :show]
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
      resources :subscriptions, only: [:index, :new, :create]
    end

    resources :plans do
      resources :plan_prices, shallow: true, except: [:index, :show]
      resources :plan_vendedores, only: [:create, :destroy], shallow: true do
        member do
          patch :toggle_active
        end
      end
    end

    resources :memberships, only: [:index, :show, :update, :destroy] do
      member do
        patch :approve
        patch :cancel
        patch :update_plan_price
      end
      collection do
        get  :benefit_requests
      end
    end

    resources :benefit_bookings, only: [], controller: "memberships" do
      member do
        patch :activate_benefit
        patch :reject_benefit
      end
    end

    resources :custom_requests, only: [:index, :show, :update, :destroy] do
      member do
        patch :assign
        patch :change_status
      end
    end

    resources :events do
      member do
        get :scanner
        post :verify_ticket
      end

      resources :tickets, only: [:index] do
        member do
          patch :mark_used, to: "events#mark_ticket_used"
        end
      end

      resources :raffles, only: [:index, :show, :new, :create, :destroy] do
        member do
          patch :draw_winner
        end
      end

      resources :vendedores do
        member do
          patch :toggle_active
        end
        collection do
          get :new_vendedor
          post :create_vendedor
        end
      end
    end
  end

end
