Cases::Application.routes.draw do
  mount Sidekiq::Web, at: '/sidekiq'

  root to: 'pages#root'

  %w(download api_reference).each do |p|
    get "/#{p}", to: "pages##{p}"
  end

  get 'buckets', to: 'buckets#list'
  get ':slug', to: 'buckets#index'
  get ':slug/pages', to: 'buckets#pages'
  post '/jobs/enqueue/:job', to: 'jobs#enqueue'

  # Don't throw an error when hackers request bad URLs
  match '*path', via: :all, to: 'pages#error_404'
end
