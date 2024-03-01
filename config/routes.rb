# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users

  draw :api_routes

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  root to: proc { [200, {}, ['University Main API APP']] }
end
