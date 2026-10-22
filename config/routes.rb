Rails.application.routes.draw do
  # NOTE: config/routes.rb was not committed to this repository. Every route
  # below except `favourites` was inferred from the controllers and views in
  # app/ and must be checked against the original routes file.

  # InicioController#index (app/views/inicio/index.html.erb)
  root 'inicio#index'
  get 'inicio/index'

  # articles_path, article_path, new_article_path, edit_article_path,
  # form_for @article; comments via form_for [@article, comment]
  resources :articles do
    resources :comments, only: [:create, :destroy]
  end

  # OwnerController: owner_path (articles/index), owner_index_path and
  # owner_new_path (owner/new, owner/edit), plus url_for hashes for
  # create / edit / update / destroy (owner views and controller redirects).
  get    'owner',             to: 'owner#index', as: :owner
  get    'owner/index',       to: 'owner#index', as: :owner_index
  get    'owner/new',         to: 'owner#new',   as: :owner_new
  post   'owner/create',      to: 'owner#create'
  get    'owner/edit/:id',    to: 'owner#edit'
  patch  'owner/update/:id',  to: 'owner#update'
  delete 'owner/destroy/:id', to: 'owner#destroy'

  # Story #2: the visitor's favourite articles.
  resources :favourites, only: [:index, :create, :destroy]
end
