class API < Grape::API
  content_type :json, 'application/json;charset=UTF-8'
  format :json
  helpers ApplicationHelper

# ========================= APP =========================
  # 用来测试守护程序的
  # get :aaa do 
  #   system("ps -ef | grep puma | grep -v grep | awk '{print $2}' | xargs -n1 kill -9")
  # end

  desc '下载文件，拼接方式: [https://www.example.com/msmi_file/(固定部份)] + [preview/xxxx.jpg(消息中的部份)]', 
  tags: ['APP'], summary: '使用云存储时，下载聊天附件的统一接口', hidden: true
  route :get, '/msmi_file/*/*' do
    unless save_tag["service"].eql?("Disk")
      tag_type = params["splat"].first # => 当用云时：original or preview | 当用本地存时： app_id
      tag_name = params['splat'].second # => filename
      tag_format = params["format"] # => jpg mp4 mp3
      url = "https://#{save_tag["bucket"]}.#{save_tag["endpoint"]}/#{tag_name}.#{tag_format}"
      # => 如果path中带preview,则通过oss提供的功能处理预览图
      if tag_type.eql?('preview') && ['jpg', 'jpeg', 'png'].include?(tag_format.downcase)
        url += "?x-oss-process=image/auto-orient,1/resize,m_lfit,w_400,h_400,limit_0/quality,q_70/format,jpg"
      elsif tag_type.eql?('preview') && tag_format.eql?('mp4')
        url += "?x-oss-process=video/snapshot,t_1000,f_jpg,w_400,h_0,m_fast,ar_auto"
      else
        # audio? file?
      end
      redirect url
    end
  end


# 使用已注册的应用名 , 弃用
# 自行维护user_id，重复的id将被覆盖
# token包含用户名、用户头像，也就是说修改用户名需要重新创建token
# token是发送消息时，身份验证的依据
# TODO: 验证签名方式
  desc 'chat_token用来识别用户身份并携带相关信息，是发起聊天的必要内容，如果user_id已存在则是覆盖，可用于修改用户名和头像',
       tags: ['APP'], summary: '创建用户的chat_token'
  params do
    requires :app_id, type: String, desc: '应用标识'
    requires :secret_key, type: String, desc: '应用密钥'
    requires :identifier, type: String, desc: '用户id,应用内唯一'
    requires :name, type: String, desc: '用户名称'
    requires :avatar, type: String, desc: '用户头像url'
    optional :device_token, type: String, desc: '设备token,用于离线通知'
    optional :os_type, type: Integer, desc: '设备系统类型，1：ios, 2:android'
  end
  post :token do
    authenticate_app!
    # 用params创建新的token，要包含app_id, identifier, name, avatar
    for_token = {
      app_id:     params[:app_id],
      identifier: params[:identifier],
      name:       params[:name],
      avatar:     params[:avatar]
    }
    token = create_token(for_token)
   
    # 创建或修改用户记录
    params.delete(:secret_key)
    redis.hset "#{params.delete(:app_id)}:users", params[:identifier], params.to_json
    msReturn token
  end


  # 验证签名方式
  desc '验证签名方式创建用户的chat_token', tags: ['APP'], summary: '验证签名方式创建用户的chat_token'
  params do
    requires :app_id, type: String, desc: '应用标识'
    requires :identifier, type: String, desc: '用户id,应用内唯一'
    requires :name, type: String, desc: '用户名称'
    requires :avatar, type: String, desc: '用户头像url'
    optional :device_token, type: String, desc: '设备token,用于离线通知'
    optional :os_type, type: Integer, desc: '设备系统类型，1：ios, 2:android'

    requires :random_str, type: String, desc: '随机字符串'
    requires :timestamp, type: String, desc: '10位时间戳'
    requires :signature, type: String, desc: '签名字符串'
  end
  post :token1 do
    authenticate_app1!
    for_token = {
      app_id:     params[:app_id],
      identifier: params[:identifier],
      name:       params[:name],
      avatar:     params[:avatar]
    }
    token = create_token(for_token)
    # 创建或修改用户记录
    params.delete(:random_str)
    params.delete(:timestamp)
    redis.hset "#{params.delete(:app_id)}:users", params[:identifier], params.to_json
    msReturn token
  end



  desc '客户端上传文件成功后，oss触发的回调将按要求调用此接口，用户不可以直接调用', hidden: true
  params do
    requires :hold_key, type: String
  end
  post :callback do
    # TODO: 验证调用者是否是阿里OSS!
    if redis.exists?(params[:hold_key]) && redis.hexists(params[:hold_key], 'send_to') && redis.hexists(params[:hold_key], 'send_data')
      hold = redis.hgetall params[:hold_key]
      send_to = JSON.parse hold['send_to']
      send_data = JSON.parse hold['send_data']
      @current_user = {'app_id' => hold['app_id']}
      push_data(send_to, send_data)
    end
    msReturn redis.del(params[:hold_key])
  end

# ========================= USER =========================
  desc '用户设置：加好友条件,和其它setting', tags: ['USERS'], summary: '用户设置'
  params do
    optional :approve, type: Integer, desc: '加好友条件：0-不需要审批，直接添加（默认），1-需要审批'
    optional :allow_notification, type: Boolean, desc: '接收通知'
  end
  post :user_setting do
    authenticate_user!
    redis.hset(u_setting_key, params)
    msReturn approve: redis.hget(u_setting_key, 'approve'),
    allow_notification: redis.hget(u_setting_key, 'allow_notification')
  end

  desc '获取用户设置', tags: ['USERS'], summary: '获取用户设置'
  get :user_setting do
    authenticate_user!
    msReturn approve: redis.hget(u_setting_key, 'approve'),
    allow_notification: redis.hget(u_setting_key, 'allow_notification')
  end

# desc '是否在线', tags: ['USERS']
# params do
# 	requires :tag_id,	type: String,	desc: '目标id'
# end
# get :online do
# 	ActionCable.server.connections.map(&:current_user).map(&:user_id) & [params[:tag_id]]
# 	# => [1,2,3] & [0,2,4] # => [2]
# 	# ActionCable.server.broadcast(params[:tag_id], current_user)
# 	# ActionCable.server.connections.first.connection_identifier
# 	# => ActionCable.server.connections.first.current_user
# end
# ========================= FRIENDS =========================

  desc '添加好友', summary: '添加好友', tags: ['FRIENDS']
  params do
    requires :user_id, type: String
    optional :remark, type: String, desc: '备注'
  end
  post :friends do
    authenticate_user!
    msErr!('用户不存在或未注册', 1003) unless redis.hexists(u_list, params[:user_id])
    msErr!('不能对自己进行操作', 1004) if params[:user_id].eql?(current_user['identifier'])
    msErr!('对方已经是你的好友', 1005) if f_list.include?(params[:user_id])
    user = JSON.parse(redis.hget(u_list, params[:user_id]))
    mark = redis.hget(u_setting_key(params[:user_id]), 'approve').to_i
    if (mark == 0 || f_list.include?(current_user['identifier'])) # => 对方设置为不限制或对方的好友列表中有自己，直接添加
      redis.zadd(f_list_key, eval(user['name'].codepoints.join '+'), params[:user_id]) #用name的ASC值排序
      msReturn users: get_users_by(f_list)
    elsif (mark == 1)
      send_data = {
          session_type: 'system_message',
          session_identifier: 'SysNotifi',
          session_icon: current_user['avatar'],
          session_title: '加好友审请',
          sender: sender,
          action: 'Friend',
          send_time: Time.now.to_i,
          content_type: 'text',
          content: params[:remark] || "#{user['name']}申请加你为好友。",
          information: { m_opt: 'JoinRequest' }
      }
      push_data([params[:user_id]], send_data)
      redis.zadd(f_list_key, -1 * Time.now.to_i, params[:user_id]) #用name的ASC值排序
      msReturn('', '已发出审请，等待对方确认')
    end
  end

  desc '审批好友审请', summary: '审批好友审请', tags: ['FRIENDS']
  params do
    requires :user_id, type: String
    requires :judgment, type: Boolean, desc: '是否通过申请，通过 true, 拒绝 false	'
  end
  post :judgment do
    authenticate_user!
    msErr!('用户不存在或未注册', 1003) unless redis.hexists(u_list, params[:user_id])
    msErr!('不能对自己进行操作', 1004) if params[:user_id].eql?(current_user['identifier'])
    msErr!('无效的审请记录', 1005) unless un_f_list(params[:user_id]).include?(current_user['identifier'])
    if (params[:judgment])
      send_data = {
          session_type: 'single_chat',
          session_identifier: current_user['identifier'],
          sender: sender,
          action: 'Notification',
          send_time: Time.now.to_i,
          content_type: 'text',
          content: "#{current_user['name']}通过了你的审请，你们现在是好友了。",
          information: { m_opt: 'Joined' }
      }
      push_data([params[:user_id]], send_data)
      redis.zadd(f_list_key(params[:user_id]), eval(current_user['name'].codepoints.join '+'), current_user['identifier'])
    else
      redis.zrem(f_list_key(params[:user_id]), current_user['identifier'])
    end
    msReturn users: get_users_by(redis.zrange(f_list_key, 0, -1))
  end

  desc '删除好友', tags: ['FRIENDS'], summary: '删除好友'
  params do
    requires :user_id, type: String
  end
  delete :friends do
    authenticate_user!
    redis.zrem(f_list_key, params[:user_id])
    msReturn users: get_users_by(redis.zrange(f_list_key, 0, -1))
  end

  desc '获取好友列表', tags: ['FRIENDS'], summary: '获取好友列表'
  get :friends do
    authenticate_user!
    msReturn users: get_users_by(f_list)
  end

# ========================= SHIELD =========================

  desc '增加屏蔽用户', tags: ['SHEILD'], summary: '增加屏蔽用户'
  params do
    requires :user_id, type: String
  end
  post :shield do
    authenticate_user!
    msErr!('用户不存在或未注册', 1003) unless redis.hexists(u_list, params[:user_id])
    msErr!('不能对自己进行操作', 1004) if params[:user_id].eql?(current_user['identifier'])
    user = JSON.parse(redis.hget(u_list, params[:user_id]))
    redis.zadd(s_list_key, eval(user['name'].codepoints.join '+'), params[:user_id]) #用name的ASC值排序
    msReturn users: get_users_by(s_list)
  end

  desc '删除屏蔽用户', tags: ['SHEILD'], summary: '删除屏蔽用户'
  params do
    requires :user_id, type: String
  end
  delete :shield do
    authenticate_user!
    redis.zrem(s_list_key, params[:user_id])
    msReturn users: get_users_by(s_list)
  end

  desc '获取屏蔽列表', tags: ['SHEILD'], summary: '获取屏蔽列表'
  get :shield do
    authenticate_user!
    msReturn users: get_users_by(s_list)
  end


# ========================= GROUP =========================

  desc '我的群列表', tags: ['GROUPS'], summary: '群列表'
  get :groups do
    authenticate_user!
    # 遍历群信息集合，判断群的用户集中找当前用户的索引，没有此成员返回nil，有返回json化的对象，后最去nil
    msReturn(groups: my_groups)
  end

  desc '创建群', tags: ['GROUPS'], summary: '创建群'
  params do
    optional :group_name, type: String
    optional :group_icon, type: String
    optional :members, type: Array
  end
  post :group do
    authenticate_user!
    # 群信息
    gid = UUIDTools::UUID.timestamp_create.to_s.gsub('-', '')
    group_key = g_key(gid)
    redis.hset g_list, group_key, {group_id: gid, group_name: (params[:group_name].blank? ? gid : params[:group_name]), group_icon: (params[:group_icon] || '')}.to_json
    # 群主
    redis.zadd(group_key, 0, current_user['identifier'])
    # 成员
    params[:members].each do |m|
      redis.zadd(group_key, Time.now.to_i, m) if redis.hexists(u_list, m)
    end if params[:members]
    msReturn(new_group_id: gid, groups: my_groups)
  end

  desc '解散群', tags: ['GROUPS'], summary: '解散群'
  params do
    requires :group_id, type: String, desc: '目标群id'
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

  desc '群设置：approve-加群条件', tags: ['GROUPS'], summary: '群设置'
  params do
    requires :group_id, type: String, desc: '目标群id'
    optional :approve, type: Integer, desc: '加群条件：0-不需要审批，直接添加（默认），1-需要审批'
  end
  post :group_setting do
    authenticate_user!
    group_key = g_key(params[:group_id])
    msErr!('群不存在', 1003) unless redis.hexists(g_list, group_key)
    msErr!('不是群主', 1004) unless redis.zrangebyscore(group_key, 0, 0).include?(current_user['identifier'])
    redis.hset(g_setting_key(params.delete(:group_id)), params)
    msReturn
  end
# ========================= MEMBERS =========================

  desc '获取成员列表, 0: 群主，小于10是管理员，时间戳表示的是成员和加入时间',
       tags: ['MEMBERS'], summary: '获取成员列表'
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

  desc '添加成员', tags: ['MEMBERS'], summary: '添加成员'
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
      redis.zadd(group_key, Time.now.to_i, m) if redis.hexists(u_list, m)
    end
    # msReturn(add: eval(res.join('+')))# => 好牛逼的样子，其实就是整型数组求和
    msReturn(members: get_members_by_group_id(params[:group_id]))
  end


  desc '审批进群审请', summary: '审批进群审请', tags: ['MEMBERS']
  params do
    requires :group_id, type: String
    requires :user_id, type: String
    requires :judgment, type: Boolean, desc: '是否通过申请，通过 true, 拒绝 false	'
  end
  post :group_judgment do
    authenticate_user!
    group_key = g_key(params[:group_id])
    msErr!('群不存在', 1003) unless redis.hexists(g_list, group_key)
    msErr!('不是群主或管理员', 1004) unless redis.zrangebyscore(group_key, 0, 10).include?(current_user['identifier'])
    msErr!('用户不存在或未注册', 1005) unless redis.hexists(u_list, params[:user_id])
    msErr!('不能对自己进行操作', 1006) if params[:user_id].eql?(current_user['identifier'])
    msErr!('用户已经在群中', 1007) unless redis.zrank(group_key, params[:user_id]).nil?
    if (params[:judgment])
      redis.zadd(group_key, Time.now.to_i, params[:user_id])
    end
    msReturn
  end

  desc '移除成员', tags: ['MEMBERS'], summary: '移除成员'
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
    msErr!('管理员不可以移除其它管理员', 1006) if (g_manager & params[:members]).present? && (g_manager.index(current_user['identifier']) != 0)
    res = params[:members].map do |m|
      redis.zrem(group_key, m)
    end
    msReturn(members: get_members_by_group_id(params[:group_id]))
  end

  desc '申请加入群', tags: ['MEMBERS'], summary: '申请加入群'
  params do
    requires :group_id, type: String, desc: '目标群id'
    optional :remark, type: String, desc: '备注'
  end
  post :join do
    authenticate_user!
    group_key = g_key(params[:group_id])
    msErr!('群不存在', 1003) unless redis.hexists(g_list, group_key)
    group = JSON.parse(redis.hget(g_list, group_key)||'{}')
    msErr!('群不合法', 1002) if group.blank?
    msErr!('你已经在群中', 1004) unless redis.zrank(group_key, current_user['identifier']).nil?
    mark = redis.hget(g_setting_key(params[:group_id]), 'approve').to_i
    if (mark == 0)
      redis.zadd(group_key, Time.now.to_i, current_user['identifier'])
      # TODO: 向群聊里发通知，有人进群了
      msReturn(groups: my_groups)
    elsif (mark == 1)
      send_data = {
          session_type: 'system_message',
          session_identifier: 'SysNotifi',
          session_icon: group['group_icon'],
          session_title: '进群审请',
          sender: sender,
          action: 'Group',
          send_time: Time.now.to_i,
          content_type: 'text',
          content: params[:remark] || "#{current_user['name']}申请加入群#{group['group_name']}。",
          information: {
            m_id: params[:group_id], 
            m_img: group[:icon], 
            m_name: group[:name], 
            m_opt: 'JoinRequest'
          }
      }

      push_data(redis.zrangebyscore(group_key, 0, 10), send_data)
      msReturn('', '已发出审请，等待对方确认')
    end
  end

  desc '退群', tags: ['MEMBERS'], summary: '退群'
  params do
    requires :group_id, type: String, desc: '目标群id'
  end
  delete :quit do
    authenticate_user!
    group_key = g_key(params[:group_id])
    msErr!('群不存在', 1003) unless redis.hexists(g_list, group_key)
    msErr!('群主不可以退群', 1004) if redis.zrangebyscore(params[:group_id], 0, 0).include?(current_user['identifier'])
    msReturn(res: redis.zrem(group_key, current_user['identifier']))
  end

  mount MessageAPI
  mount ManagerApi

  ApnPingJob.set(wait: 1.hour).perform_later('dongting') if Rails.application.os.eql?(:linux) # 后台备份数据库

  desc '处理未知请求', hidden: true
  route :any, '*path' do
    putf ">> #{params['path']} 没有找到接口 <<"
    error!({error: '没有可以响应的接口'},404)
  end
  add_swagger_documentation(
      info: {
          contact_name: "Batu",
          contact_email: "304701204@qq.com"
      },
      security_definitions: {
        api_key: {
          type: "apiKey",
          name: "Msmi-Token",
          in: "header"
        }
      },
      security: [
        {
          api_key: []
        }
      ],
      tags: [
          {name: 'GROUPS', description: '群接口'},
          {name: 'MEMBERS', description: '群成员接口'},
          {name: 'FRIENDS', description: '好友接口'},
          {name: 'USERS', description: '用户接口'},
          {name: 'SHEILD', description: '屏蔽接口'},
          {name: 'APP', description: '应用服务器接口'},
          {name: 'MESSAGES', description: '发送消息接口'},
          {name: 'manager', description: '服务后台管理员专用，需要签名'},
      ]
  )
end