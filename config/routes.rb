Rails.application.routes.draw do
	mount API => '/'
  mount ActionCable.server => '/cable'
end
