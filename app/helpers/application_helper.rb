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

	# 验证token，获取用户
  def authenticate_user!
  	begin
  		@current_user, _  = decode_token(headers['Msmi-Token']) # 找不到会抛异常
      msErr!('用户身份未通过验证', 1007) if @current_user.nil? 
      msErr!('app_id未通过验证', 1006) unless redis_app.sismember('app_names', @current_user['app_id'])
    rescue StandardError
    end
  end

  def authenticate_user token
    begin
      @current_user, _  = decode_token(token) # 找不到会抛异常
    rescue StandardError
    end
  end

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

  def ms_send tag, msg
    send_to = "#{current_user['app_id']}_#{tag}_online"
    send_data = {
      from_id: current_user['user_id'],
      from_name: current_user['user_id'],
      from_avatar: current_user['user_id'],
      from_time: Time.now.to_i,
      content: msg
    }
    send_res = ActionCable.server.broadcast(send_to, send_data) 
    if send_res == 0
      hold = {send_to: send_to, send_data: send_data }
      redis_msg.setex("#{Time.now.to_i}_#{send_to}", 1.hour.to_i, hold.to_json)
    end
  end

  def redis_app
    @redis_app ||= Redis.new(driver: :hiredis, db: 1)
  end

  def redis_msg
    @redis_msg ||= Redis.new(driver: :hiredis, db: 2)
  end

end
