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
        get :current_course_id
        get :find_user
        get :fetch_user_details
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
        get :current_user_branches
      end
    end
    resources :semesters
    resources :subjects do
      collection do
        get :current_course_subjects
      end
    end
    resources :students do
      collection do
        get :current_course_students
        get :find_students_to_enter_marks
        get :unassigned_students
      end
    end
    resources :excel_sheets do
      collection do
        get :uploaded_sheets_name
      end
    end

    resources :examination_blocks do
      member do
        post :assign_students
      end
      collection do
        get :available_blocks
      end
    end

    resources :examination_names
    resources :examination_times
    resources :examination_types

    resources :exam_time_tables do
      collection do
        post :handle_print, format: :pdf
        get :all_unique_exam_time_table
        get :find_subjects_without_time_table
        get :unique_examination_dates # get_examination_dates
        get :exam_related_subjects # fetch_subjects
      end
    end

    resources :time_table_block_wise_reports

    resources :block_extra_configs

    resources :supervisions do
      collection do
        get :faculties_without_supervisions
        get :unique_examination_dates
      end
    end

    resources :other_duties do
      collection do
        get :fetch_unsupervised_faculties
      end
    end

    resources :marks_entries
    resources :student_marks do
      member do
        post :lock_marks
        post :unlock_marks
      end
      collection do
        get :marksheet_data
        post :publish_marks
        post :unpublish_marks
        get :retrieve_unique_subjects_for_lock_marks
        get :retrieve_unique_subjects_for_unlock_marks
      end
    end
  end
end
