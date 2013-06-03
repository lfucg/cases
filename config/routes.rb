Geoevents::Application.routes.draw do
  get ':slug', to: 'buckets#index'
  get ':slug/pages', to: 'buckets#pages'
  get 'buckets', to: 'buckets#list'
  post '/jobs/enqueue/:job', to: 'jobs#enqueue'
end
