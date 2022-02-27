Rails.application.routes.draw do
  root 'licenses#index'
  post '/licenses/new'
  get '/licenses/form_possible_versions'
end
