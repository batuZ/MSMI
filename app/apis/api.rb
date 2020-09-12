class API < Grape::API
	prefix :api
	content_type :json, 'application/json;charset=UTF-8'
	format :json

	mount V0::Root
end