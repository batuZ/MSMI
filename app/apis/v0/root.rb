class V0::Root < Grape::API
	version 'v0', using: :path
	mount MessageAPI
end