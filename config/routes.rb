Geoevents::Application.routes.draw do
  get 'buckets', to: 'buckets#list'
  get ':slug', to: 'buckets#index'
  get ':slug/pages', to: 'buckets#pages'
  post '/jobs/enqueue/:job', to: 'jobs#enqueue'
end
