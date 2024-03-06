# frozen_string_literal: true

scope :api do
  scope :v1 do
    use_doorkeeper do
      skip_controllers :authorizations, :applications, :authorized_applications
    end
  end
end

namespace :api, defaults: { format: :json } do # rubocop:disable Metrics/BlockLength
  namespace :v1 do # rubocop:disable Metrics/BlockLength
    get '/get_authorization_details', to: 'home#authorization_details'
    get '/check_login_status', to: 'users#check_login_status'

    resources :users do
      collection do
        get :find_user
        get :assigned_role_users
        get :faculty_names
        post :create_super_admin
        post :send_otp
      end

      member do
        post :assign_role
        post :revoke_role
      end
    end

    resources :roles do
      collection do
        get :fetch_roles
      end
    end

    resources :courses
    resources :branches do
      collection do
        get :all_branches
      end
    end
    resources :semesters
    resources :subjects
    resources :students
    resources :excel_sheets do
      collection do
        get :uploaded_sheets_name
      end
    end
  end
end
