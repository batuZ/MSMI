class API < Grape::API
	content_type :json, 'application/json;charset=UTF-8'
	format :json
	helpers	ApplicationHelper


	# 应用的唯一标识，不能重复，最小长度为两个字符
	# 功能类似namespace
	# 未注册不能创建usertoken
	desc '创建app'
	params do
		requires :app, type: String, desc: 'app名称或标识字符串，全局唯一'
	end
	post :app do
		msErr!('应用已存在', 1003) if app?(params[:app])
		msErr!('应用名称不合法', 1005) if params[:app].size < 3 # => or other
		sk = UUIDTools::UUID.timestamp_create.to_s.gsub('-','')
		redis.hset 'apps', params[:app], {
			create_time: Time.now.to_i,
			max_lenght: 1.year,
			max_users: 100,
			secret_key: sk,
			ownner: '',
			email: ''
		}.to_json
		msReturn(app_name: params[:app], secret_key: sk)
	end


	# 使用已注册的应用名
	# 自行维护user_id，重复的id将被覆盖
	# token包含用户名、用户头像，也就是说修改用户名需要重新创建token
	# token是发送消息时，身份验证的依据
	# TODO: 验证签名方式
	desc '创建用户token，如果user_id已存在则是覆盖，可用于修改用户名和头像'	
	params do
		requires :app_id,	type: String,	desc: '应用标识'
		requires :secret_key,	type: String,	desc: '应用密钥'
		requires :user_id,	type: String,	desc: '用户id,应用内唯一'
		requires :user_name,	type: String,	desc: '用户名称'
		requires :avatar_url,	type: String,	desc: '用户头像url'
	end
	post :token do
		msErr!('app_id或secret_key不合法', 1003) unless app?(params[:app_id])
		msErr!('app_id或secret_key不合法', 1003) unless app_info(params[:app_id])['secret_key'].eql?(params[:secret_key])
		# 用params创建新的token，不需要包含secret_key
		params.delete(:secret_key)
		token = create_token(params)
		# 创建或修改用户记录
		redis.hset "#{params.delete(:app_id)}:users", params.delete(:user_id), params.to_json
		msReturn token
	end

	desc '创建群'
	params do
		requires :group_name, type: String
		requires :group_icon, type: String
		requires :members, type: Array
	end
	post :create_group do
		authenticate_user!
		gid = UUIDTools::UUID.timestamp_create.to_s.gsub('-','')
		group_info = {
			group_name: params[:group_name],
			group_icon: params[:group_icon]
		}.to_json
		# 群信息
		redis.hset "#{current_user['app_id']}:groups", gid, group_info
		# 群成员
		redis.zadd(gid, 0, current_user['user_id'])
		params[:members].each do |m|
			redis.zadd(gid, Time.now.to_i, m) if redis.hexists("#{current_user['app_id']}:users", m)
		end
		msReturn group_id
	end

	desc '添加成员'
	params do
		requires :group_id, type: String
		requires :members, type: Array
	end
	post :add_members do
		authenticate_user!
		# app:groups 中查询群是否存在
		msErr!('群不存在', 1003) unless redis.hexists("#{current_user['app_id']}:groups", params[:group_id])
		# 群成员列表中查询是否有权限，0：创建者，1~10：管理员，时间戳：普通成员，方法：获取score为1~0的成员，判断当前用户存在
		msErr!('不是群主或管理员', 1004) unless redis.zrangebyscore(params[:group_id], 0, 10).include?(current_user['user_id'])
		res = params[:members].map do |m|
			redis.zadd(params[:group_id], Time.now.to_i, m) if redis.hexists("#{current_user['app_id']}:users", m)
		end
		msReturn(add: eval(res.join('+')))# => 好牛逼的样子，其实就是整型数组求和，返回成功加入群的人数
	end

	desc '移除成员'
	params do
		requires :group_id, type: String
		requires :members, type: Array
	end
	post :remove_members do
		authenticate_user!
		msErr!('群不存在', 1003) unless redis.hexists("#{current_user['app_id']}:groups", params[:group_id])
		msErr!('不是群主或管理员', 1004) unless redis.zrangebyscore(params[:group_id], 0, 10).include?(current_user['user_id'])
		res = params[:members].map do |m|
			redis.zrem(params[:group_id], m) 
		end
		msReturn
	end

	desc '解散群'
	params do
		requires :group_id,	type: String,	desc: '目标群id'
	end
	delete :delete_group do
		authenticate_user!
		msErr!('群不存在', 1003) unless redis.hexists("#{current_user['app_id']}:groups", params[:group_id])
		msErr!('不是群主', 1004) unless redis.zrangebyscore(params[:group_id], 0, 0).include?(current_user['user_id'])
		redis.hdel("#{current_user['app_id']}:groups", params[:group_id])
		redis.del(params[:group_id])
		msReturn
	end

	desc '是否在线'
	params do
		requires :tag_id,	type: String,	desc: '目标id'
	end
	get :online do
		ActionCable.server.connections.map(&:current_user).map(&:user_id) & [params[:tag_id]]
		# => [1,2,3] & [0,2,4] # => [2]
		# ActionCable.server.broadcast(params[:tag_id], current_user)
		# ActionCable.server.connections.first.connection_identifier
		# => ActionCable.server.connections.first.current_user
	end
	mount MessageAPI
end

=begin  结构

app:
创建app 
	1、判断存在
	redis.hexists 'apps', 'appname'
	2、创建app, appinfo中包含应用的全局设置，如用户上限，有效期等，secret_key用于处理用户token时的身份验证，
	redis.hset 'apps', {'appname': appinfo.json} # => appinfo.json: secret_key, ownner_name, create_date ... 
	
user:
创建token
	1、验证app标识和密钥
	2、创建或修改用户
	3、创建token

发送xioxi

=end