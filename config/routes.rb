AdvidiTest::Application.routes.draw do
  resources :campaigns, :only => [:show]
end
