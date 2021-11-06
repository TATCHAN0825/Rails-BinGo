Rails.application.routes.draw do
  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?
  devise_for :users
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  root 'home#index'
  resources :boards
  post 'boards/:id/join' => 'boards#join', as: :boards_join
  get 'profile/:name' => 'profile#show'
end
