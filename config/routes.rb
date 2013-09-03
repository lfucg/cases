require 'sidekiq/web'

Geoevents::Application.routes.draw do
  mount Sidekiq::Web, at: '/sidekiq'

  get 'buckets', to: 'buckets#list'
  get ':slug', to: 'buckets#index'
  get ':slug/pages', to: 'buckets#pages'
  post '/jobs/enqueue/:job', to: 'jobs#enqueue'
end
