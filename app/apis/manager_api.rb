class ManagerApi < Grape::API

	# 签名参数
	params do
		requires :random_str, type: String, desc: '随机字符串'
		requires :timestamp, type: String, desc: '10位时间戳'
		requires :signature, type: String, desc: '签名字符串'
	end


  resources :manager do

  	desc '创建应用', summary: '创建应用'
  	params do
  		requires :app_name, type: String
  		optional :ownner, type: String, desc: 'app管理员'
	    optional :email, type: String, desc: '联系方式'
	    optional :max_users, type: Integer, desc: '人数上限'
	    optional :lease_length, type: Integer, desc: '租赁期，秒'
  	end
  	post :create_app do
      authenticate_manager!
  		msErr!('应用已存在', 1003) if app?(params[:app_name])
	    msErr!('应用名称不合法', 1005) if params[:app_name].size < 3 # => or other
	    sk = UUIDTools::UUID.timestamp_create.to_s.gsub('-', '')
	    redis.hset 'apps', params[:app_name], {
	        create_time: Time.now.to_i,
	        lease_length: params[:lease_length] || 1.year,
	        max_users: params[:max_users] || 100,
	        secret_key: sk,
	        ownner: params[:ownner] || '',
	        email: params[:email] || ''
	    }.to_json
	    msReturn(app_name: params[:app_name], secret_key: sk)
  	end


  	desc '获取指定应用详情', summary: '获取指定应用详情'
  	params do
  		requires :app_name, type: String
  	end
  	post :app do
      authenticate_manager!
			msReturn(
        app: JSON.parse(redis.hget('apps', params[:app_name]) || '{}' ).tap{|s| s.delete('secret_key') },
        user_number: 123,
        group_number: 123,
        cache_message_number: 123,
        oss_resource_number: 123
        ) 
  	end


  	desc '获取应用列表', summary: '获取应用列表'
  	post :apps do
  		authenticate_manager!
      # msReturn apps: redis.hgetall('apps').map{|k,v| JSON.parse(v).merge(app: k)}
  		msReturn apps: redis.hkeys('apps')
  	end


  	desc '编辑指定应用属性', summary: '编辑指定应用属性'
  	params do
      requires :app_name, type: String
  		optional :ownner, type: String, desc: 'app管理员'
	    optional :email, type: String, desc: '联系方式'
	    optional :max_users, type: Integer, desc: '人数上限'
	    optional :lease_length, type: Integer, desc: '租赁期，秒'
	    optional :secret_key, type: Integer, desc: '设置新的密匙'
  	end
  	post :set_app do
      authenticate_manager!
      msReturn apps: redis.hgetall('apps').map{|k,v| JSON.parse(v).merge(app: k)}
  	end


    desc '设置指定应用APN证书', summary: '设置指定应用APN证书'
    params do
      requires :app_name, type: String
      requires :product, type: String
      requires :sandbox, type: String
    end
    post :apn_key do
      authenticate_manager!
      msReturn
    end


  	desc '获取数据库状态', summary: '获取数据库状态'
  	post :redis do
      authenticate_manager!
  		msReturn redis.info
  	end


    desc '设置签名密钥', summary: '设置签名密钥'
    params do
      requires :new_key, type: String
    end
    post :manager_key do
      authenticate_manager!

      dir = './config/keys'
      FileUtils.mkdir_p(path) unless File.exists?(dir)
      File.open("#{dir}/manager_key", 'w') do |f|
        f.syswrite(params[:new_key])
        Rails.configuration.x.m_key = params[:new_key]
      end
      
      msReturn
    end


  end
end