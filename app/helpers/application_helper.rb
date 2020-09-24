module ApplicationHelper

	def is_online *ids
		online_ids = ActionCable.server.connections.map{|connect| connect.current_user.identifier}
		ids & online_ids
	end

	def create_token params
    token = JWT.encode(params, 'test_hash_key')
    header('Msmi-Token', token)
    token
	end

	def decode_token token
		JWT.decode(token, 'test_hash_key')
	end

  # 判断app是否有效
  def app? app_name
    redis.hexists 'apps', app_name
  end

	# 验证token，获取用户
  def authenticate_user!
  	begin
  		@current_user, _  = decode_token(headers['Msmi-Token']) # 找不到会抛异常
      msErr!('用户身份未通过验证', 1007) if @current_user.nil? 
      msErr!('app_id未通过验证', 1006) unless app?(@current_user['app_id'])
    rescue StandardError
    end
  end

  # connection 验证用户用的
  def authenticate_user token
    begin
      @current_user, _  = decode_token(token) # 找不到会抛异常
    rescue StandardError
    end
  end

  # 获取当前用户
  def current_user
  	@current_user
  end

  # response
  def msReturn dic={}, msg=''
  	status 200
  	{ ms_content: dic, ms_code: 1000, ms_message: msg }
  end

  def msErr! msg, code
  	throw :error, message: {ms_message: msg, ms_code: code}, status: 200, headers: header
  end

  # redis对象
  def redis
    @redis ||= Redis.new(driver: :hiredis, url: ActionCable.server.config.cable[:url])
  end

  # 获取app信息
  def app_info app_name
    JSON.parse(redis.hget('apps', app_name))
  end

  # 获取群信息
  def group_info app_id, group_id
    JSON.parse(redis.hget("#{app_id}:groups", group_id))
  end

  # 群列表的key
  def g_list
    "#{current_user['app_id']}:groups"
  end

  # 群的key
  def g_key g_id 
    "#{g_list}:#{g_id}"
  end

  # 用户列表
  def u_list
    "#{current_user['app_id']}:users"
  end

  # 用户key
  def u_key u_id=nil
    "#{u_list}:#{u_id||current_user['user_id']}"
  end

  # 好友列表
  def f_list
    "#{u_key}:friends"
  end

  # 屏蔽表列
  def s_list
    "#{u_key}:shield"
  end

  def sender
    {
      identifier: current_user['user_id'],
      name: current_user['user_name'],
      avatar:  current_user['avatar_url']
    }
  end
end
