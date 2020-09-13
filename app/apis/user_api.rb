class UserAPI < Grape::API
	resources :user do

		desc '创建token'	
		params do
			requires :app_id,	type: String,	desc: '目标应用组id'
			requires :user_id,	type: String,	desc: '用户id'
			requires :user_name,	type: String,	desc: '用户名称'
			requires :avatar_url,	type: String,	desc: '用户头像'
		end
		post :token do
			msErr!('应用id不合法', 1003) unless redis_app.sismember('app_names', params[:app_id])
			msReturn create_token(params)
		end

		desc '是否在线'
		params do
			requires :tag_id,	type: String,	desc: '目标id'
		end
		get :online do
			ActionCable.server.connections.map(&:current_user).map(&:user_id) & [params[:tag_id]]
			# => [1,2,3] & [0,2,4] # => [2]
		end

	end
end
