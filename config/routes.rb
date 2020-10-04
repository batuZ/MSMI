Rails.application.routes.draw do
	mount(GrapeSwaggerRails::Engine => 'doc') if Rails.env.eql?('development')
	mount API => '/'
  mount ActionCable.server => '/cable'
end
