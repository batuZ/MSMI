module ApplicationHelper

#======================= token =================================

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
      @current_user, _ = decode_token(headers['Msmi-Token']) # 找不到会抛异常
      msErr!('用户身份未通过验证', 1007) if @current_user.nil?
      msErr!('app_id未通过验证', 1006) unless app?(@current_user['app_id'])
    rescue StandardError
    end
  end

  # connection 验证用户用的
  def authenticate_user token
    begin
      @current_user, _ = decode_token(token) # 找不到会抛异常
    rescue StandardError
    end
  end

  # 获取当前用户
  def current_user
    @current_user
  end

  def is_online *ids
    online_ids = ActionCable.server.connections.map { |connect| connect.current_user.identifier }
    ids & online_ids
  end

  #======================= response =================================

  # response
  def msReturn dic = {}, msg = 'OK'
    status 200
    {ms_content: dic, ms_code: 1000, ms_message: msg}
  end

  def msErr! msg, code
    throw :error, message: {ms_message: msg, ms_code: code}, status: 200, headers: header
  end

  #======================= redis =================================

  # redis对象
  def redis
    $REDIS ||= Redis.new(driver: :hiredis, url: ActionCable.server.config.cable[:url])
  end

  # 获取app信息
  def app_info app_name
    JSON.parse(redis.hget('apps', app_name))
  end

  # 判断app是否有效
  def app? app_name
    redis.hexists 'apps', app_name
  end

  # 推送数据，或离线缓存
  def push_data tagets_arr, send_data
    res = 0
    tagets_arr.each do |tag|
      send_to = u_key(tag)
      is_pushed = ActionCable.server.broadcast(send_to, send_data)
      if is_pushed == 0
        hold = {send_to: send_to, send_data: send_data}
        redis.setex("#{send_to}:messages:#{Time.now.to_i}", 1.hour.to_i, hold.to_json)
      end
      res += is_pushed
    end
    res
  end

  #======================= groups =================================

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

  # 群设置的key
  def g_setting_key g_id
    "#{g_key(g_id)}:setting"
  end

  # 有我的群
  def my_groups
    redis.hscan(g_list, 0).second.map { |g_info| redis.zrank(g_info.first, current_user['identifier']) ? JSON.parse(g_info.second) : nil }.compact
  end

  # 我创建的群
  def mine_gropus
    redis.hscan(g_list, 0).second.map { |g_info| redis.zrank(g_info.first, current_user['identifier']) == 0 ? JSON.parse(g_info.second) : nil }.compact
  end

  # 获取群中成员详细信息
  def get_members_by_group_id group_id
    group_key = g_key(group_id)
    redis.zrem(group_key, (redis.zrange(group_key, 0, -1) - redis.hkeys(u_list)) | [nil]) # => 移除群中无效的成员
    redis.hmget(u_list, redis.zrange(group_key, 0, -1))
        .zip(redis.zrange(group_key, 0, -1, withscores: true))
        .map { |e| JSON.parse(e.first).merge!({member_type: e.second.second}) if e.first }
        .compact
  end

  #======================= user =================================

  # 用户列表
  def u_list
    "#{current_user['app_id']}:users"
  end

  # 指定用户的key
  def u_key u_id = nil
    "#{u_list}:#{u_id || current_user['identifier']}"
  end

  # 用户设置的key
  def u_setting_key u_id = nil
    "#{u_key(u_id)}:setting"
  end

  # 发送者的信息
  def sender
    {
        identifier: current_user['identifier'],
        name: current_user['name'],
        avatar: current_user['avatar']
    }
  end

  # 获取用户信息
  def get_users_by identifiers
    if identifiers.present?
      redis.hmget(u_list, identifiers).compact.map { |a| JSON.parse a }
    else
      []
    end
  end

  #======================= friends shield =================================

  # 好友列表键
  def f_list_key u_id = nil
    "#{u_key(u_id)}:friends"
  end

  # 好友列表
  def f_list
    redis.zrangebyscore(f_list_key, 0, "+inf")
  end

  # 指定用户的好友审请列表
  def un_f_list u_id
    redis.zrangebyscore(f_list_key(u_id), "-inf", -2)
  end

  # 指定用户的屏蔽表列键， nil=当前用户的 # => 'mapplay:users:Nigulash_ShuFen:shield'
  def s_list_key u_id = nil
    "#{u_key(u_id)}:shield"
  end

  # 指定用户的屏蔽表列， nil=当前用户的 # => ['Nigulash_ShuFen', 'Nigulash_ShuFen']
  def s_list u_id = nil
    redis.zrange(s_list_key(u_id), 0, -1)
  end

  #======================= file =================================

  def save_file tempfile_path
    if File.exist?(tempfile_path) && File.file?(tempfile_path)
      file_name = File.basename(tempfile_path)
      if save_tag["service"].eql?("Disk")
        file_path = File.join(save_tag["root"], current_user['app_id'], file_name)
        FileUtils.mkdir_p(File.dirname(file_path), :mode => 0700)
        FileUtils.move(tempfile_path, file_path)
        ["#{current_user['app_id']}/#{file_name}", "#{current_user['app_id']}/#{file_name}"]
      else
        al_bucket.put_object(File.basename(tempfile_path), :file => tempfile_path)
        ["msmi_file/original/#{file_name}", "msmi_file/preview/#{file_name}"]
      end
    end
  end

  def al_bucket
    @al_client ||= Aliyun::OSS::Client.new(
        endpoint: save_tag['endpoint'],
        access_key_id: save_tag['access_key_id'],
        access_key_secret: save_tag['access_key_secret'])
    @al_client.get_bucket(save_tag['bucket'])
  end

  def save_tag
    # => Disk {"service"=>"Disk", "root"=>"/Users/Batu/MyData/MSMI/public"}
    # => Service {"service"=>"Aliyun", "access_key_id"=>"LTAstqjJprAvcw", "access_key_secret"=>"2NAqquRz742595Yi1mU", "endpoint"=>"oss-cn-beijing.aliyuncs.com", "bucket"=>"msmi-mapplaytest"}
    @save_tag ||= Rails.application.config_for(:storage, env: Rails.application.config.active_storage.service.to_s)
  end

  # 自动创建bucket太复杂，包括命名，权限，生命管理等，暂时不用
  # oss 设置：
  # => 1 创建一个与app绑定的bucket
  # => 2 设置为公共读
  # => 3 根据需要设置生命周期，定时清理
  # => 4 创建图片或视频的预览图
  # => 5 视频和音频的时长
  def _create_bucket
    # 用app_id创建一个bucket
    # 修正app_id使其可以用来创建bucket,只允许小写字母、数字、短横线（-），且不能以短横线开头或结尾
    appid = current_user['app_id'].downcase.delete(current_user['app_id'].downcase.delete('-0123456789abcdefghigklmnopqrstuvwxyz'))
    bucket_name = "msmi-#{appid}"
    al_client.create_bucket(bucket_name) unless al_client.bucket_exists?(bucket_name)
    bucket = al_client.get_bucket(bucket_name)
    bucket.acl = Aliyun::OSS::ACL::PUBLIC_READ
    puts bucket.acl
    bucket
  end

end



