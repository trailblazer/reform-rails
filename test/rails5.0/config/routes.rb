Rails.application.routes.draw do
  # get ':controller(/:action(/:id(.:format)))'

  resources :songs
end
