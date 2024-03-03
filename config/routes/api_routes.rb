# frozen_string_literal: true

scope :api do
  scope :v1 do
    use_doorkeeper do
      skip_controllers :authorizations, :applications, :authorized_applications
    end
  end
end

namespace :api, defaults: { format: :json } do
  namespace :v1 do
    get '/get_authorization_details', to: 'home#authorization_details'
    get '/check_login_status', to: 'users#check_login_status'

    resources :users do
      collection do
        post :create_super_admin
      end
    end

    resources :courses
    resources :branches
    resources :semesters
    resources :subjects
    resources :students
    resources :excel_sheets
  end
end
