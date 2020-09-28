class API < Grape::API
	content_type :json, 'application/json;charset=UTF-8'
	format :json
	helpers	ApplicationHelper

# ========================= APP =========================
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


# ========================= USER =========================

	# 使用已注册的应用名
	# 自行维护user_id，重复的id将被覆盖
	# token包含用户名、用户头像，也就是说修改用户名需要重新创建token
	# token是发送消息时，身份验证的依据
	# TODO: 验证签名方式
	desc '创建用户token，如果user_id已存在则是覆盖，可用于修改用户名和头像'	
	params do
		requires :app_id,	type: String,	desc: '应用标识'
		requires :secret_key,	type: String,	desc: '应用密钥'
		requires :identifier,	type: String,	desc: '用户id,应用内唯一'
		requires :name,	type: String,	desc: '用户名称'
		requires :avatar,	type: String,	desc: '用户头像url'
	end
	post :token do
		msErr!('app_id或secret_key不合法', 1003) unless app?(params[:app_id])
		msErr!('app_id或secret_key不合法', 1003) unless app_info(params[:app_id])['secret_key'].eql?(params[:secret_key])
		# 用params创建新的token，不需要包含secret_key
		params.delete(:secret_key)
		token = create_token(params)
		# 创建或修改用户记录
		redis.hset "#{params.delete(:app_id)}:users", params[:identifier], params.to_json
		msReturn token
	end

	desc '如果user不在好友列表则创建好友记录，如果已存在，则覆盖好友信息', summary: '添加好友, 或修改好友信息'
	params{ requires :user_id, type: String }
	post :friends do
		authenticate_user!
		msErr!('用户不存在或未注册', 1003) unless redis.hexists(u_list, params[:user_id])
		msErr!('不能对自己进行操作', 1004) if params[:user_id].eql?(current_user['identifier'])
		user = JSON.parse(redis.hget(u_list, params[:user_id]))
		redis.zadd(f_list, eval(user['name'].codepoints.join'+'), params[:user_id]) #用name的ASC值排序
		msReturn users: get_users_by(redis.zrange(f_list, 0, -1))
	end

	desc '删除好友'
	params do
		requires :user_id, type: String
	end
	delete :friends do
		authenticate_user!
		redis.zrem(f_list, params[:user_id])
		msReturn users: get_users_by(redis.zrange(f_list, 0, -1))
	end

	desc '获取好友列表'
	get :friends do
		authenticate_user!
		msReturn users: get_users_by(redis.zrange(f_list, 0, -1))
	end

	desc '增加屏蔽用户'
	params do
		requires :user_id, type: String
	end
	post :shield do
		authenticate_user!
		msErr!('用户不存在或未注册', 1003) unless redis.hexists(u_list, params[:user_id])
		msErr!('不能对自己进行操作', 1004) if params[:user_id].eql?(current_user['identifier'])
		user = JSON.parse(redis.hget(u_list, params[:user_id]))
		redis.zadd(s_list_key, eval(user['name'].codepoints.join'+'), params[:user_id]) #用name的ASC值排序
		msReturn users: get_users_by(s_list)
	end

	desc '删除屏蔽用户'
	params do
		requires :user_id, type: String
	end
	delete :shield do
		authenticate_user!
		redis.zrem(s_list_key, params[:user_id])
		msReturn users: get_users_by(s_list)
	end

	desc '获取屏蔽列表'
	get :shield do
		authenticate_user!
		msReturn users: get_users_by(s_list)
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

# ========================= GROUP =========================

	desc '我的群列表'
	get :groups do
		authenticate_user!
		# 遍历群信息集合，判断群的用户集中找当前用户的索引，没有此成员返回nil，有返回json化的对象，后最去nil
		msReturn(groups: my_groups) 
	end

	desc '创建群'
	params do
		optional :group_name, type: String
		optional :group_icon, type: String
		optional :members, type: Array
	end
	post :group do
		authenticate_user!
		# 群信息
		gid = UUIDTools::UUID.timestamp_create.to_s.gsub('-','')
		group_key = g_key(gid)
		redis.hset g_list, group_key, { group_id: gid, group_name: (params[:group_name].blank? ? gid : params[:group_name]), group_icon: (params[:group_icon]||'') }.to_json
		# 群主
		redis.zadd(group_key, 0, current_user['identifier'])
		# 成员
		params[:members].each do |m|
			redis.zadd(group_key, Time.now.to_i, m) if redis.hexists("#{current_user['app_id']}:users", m)
		end if params[:members]
		msReturn(new_group_id: gid, groups: my_groups) 
	end

	desc '解散群'
	params do
		requires :group_id,	type: String,	desc: '目标群id'
	end
	delete :group do
		authenticate_user!
		group_key = g_key(params[:group_id])
		msErr!('群不存在', 1003) unless redis.hexists(g_list, group_key)
		msErr!('不是群主', 1004) unless redis.zrangebyscore(group_key, 0, 0).include?(current_user['identifier'])
		redis.hdel(g_list, group_key)
		redis.del(group_key)
		msReturn(groups: my_groups)  
	end

# ========================= MEMBERS =========================

	desc '获取成员列表, 0: 群主，小于10是管理员，时间戳表示的是成员和加入时间'
	params do
		requires :group_id, type: String
	end
	get :members do
		authenticate_user!
		group_key = g_key(params[:group_id])
		msErr!('群不存在', 1003) unless redis.hexists(g_list, group_key)
		msErr!('不是群成员', 1003) if redis.zrank(group_key, current_user['identifier']).nil?
		msReturn(members: get_members_by_group_id(params[:group_id]))
	end

	desc '添加成员'
	params do
		requires :group_id, type: String
		requires :members, type: Array
	end
	post :members do
		authenticate_user!
		group_key = g_key(params[:group_id])
		msErr!('群不存在', 1003) unless redis.hexists(g_list, group_key)
		# 群成员列表中查询是否有权限，0：创建者，1~10：管理员，时间戳：普通成员，方法：获取score为1~0的成员，判断当前用户存在
		msErr!('不是群主或管理员', 1004) unless redis.zrangebyscore(group_key, 0, 10).include?(current_user['identifier'])
		params[:members].each do |m|
			redis.zadd(group_key, Time.now.to_i, m) if redis.hexists("#{current_user['app_id']}:users", m) 
		end
		# msReturn(add: eval(res.join('+')))# => 好牛逼的样子，其实就是整型数组求和，返回成功加入群的人数
		msReturn(members: get_members_by_group_id(params[:group_id]))
	end

	desc '移除成员'
	params do
		requires :group_id, type: String
		requires :members, type: Array
	end
	delete :members do
		authenticate_user!
		group_key = g_key(params[:group_id])
		msErr!('群不存在', 1003) unless redis.hexists(g_list, group_key)
		g_manager = redis.zrangebyscore(group_key, 0, 10)
		msErr!('不是群主或管理员', 1004) unless g_manager.include?(current_user['identifier'])
		msErr!('不可以移除自已', 1005) if params[:members].include?(current_user['identifier'])
		# 这里包含以下内容：
		# 1、(g_manager&params[:members]).present? ，群管数组和参数数组求交集，如果有内容，说明参数组包含管理员
		# 2、g_manager.index(current_user['user_id'])，在群管数组中找到自己的下标，如果不是群主（下标为0）时，没有权限移除其他管理员
		msErr!('管理员不可以移除其它管理员', 1006) if (g_manager&params[:members]).present? && (g_manager.index(current_user['identifier']) != 0)
		res = params[:members].map do |m|
			redis.zrem(group_key, m) 
		end
		msReturn(members: get_members_by_group_id(params[:group_id]))
	end

	desc '加入群'
	params do
		requires :group_id,	type: String,	desc: '目标群id'
	end
	post :join do
		authenticate_user!
		group_key = g_key(params[:group_id])
		msErr!('群不存在', 1003) unless redis.hexists(g_list, group_key)
		msReturn(res: redis.zadd(group_key, Time.now.to_i, current_user['identifier']))
	end

	desc '退群' 
	params do
		requires :group_id,	type: String,	desc: '目标群id'
	end
	delete :quit do
		authenticate_user!
		group_key = g_key(params[:group_id])
		msErr!('群不存在', 1003) unless redis.hexists(g_list, group_key)
		msErr!('群主不可以退群', 1004) if redis.zrangebyscore(params[:group_id], 0, 0).include?(current_user['identifier'])
		msReturn(res: redis.zrem(group_key, current_user['identifier']))
	end

	mount MessageAPI
end