class API < Grape::API
	content_type :json, 'application/json;charset=UTF-8'
	format :json
	helpers	ApplicationHelper

	desc '创建app'
	params do
		requires :app_name, type: String, desc: 'app名称'
	end
	post :app do
		msErr!('应用已存在', 1003) if redis_app.sismember('app_names', params[:app_name])
		msErr!('应用名称不合法', 1005) if params[:app_name].size < 3 # => or other
		redis_app.sadd 'app_names', params[:app_name]
		msReturn
	end

	mount MessageAPI
	mount UserAPI
end