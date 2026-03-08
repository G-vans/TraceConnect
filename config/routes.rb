Rails.application.routes.draw do
  # Radar Dashboard — the HQ command center
  root "radar#index"

  # Ask TraceConnect — natural language query sidebar
  post "ask", to: "ask#query"

  # Conversations Feed — searchable, filterable list
  resources :conversations, only: [:index, :show]

  # Consent Dashboard — per-branch consent tracking
  resources :consent, only: [:index]

  # Performance Board — charts and rankings
  resources :performance, only: [:index]

  # Health check endpoint
  get "up" => "rails/health#show", as: :rails_health_check
end
