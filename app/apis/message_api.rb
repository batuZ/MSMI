class MessageAPI < Grape::API
  resources :message do

    desc '单聊', summary: '单聊', tags: ['MESSAGES']
    params do
      requires :user_id, type: String, desc: '目标id'
      requires :content_type, type: String, desc: '消息类型'
      optional :content, type: String, desc: '消息中的文字内容'
      optional :file, type: ActionDispatch::Http::UploadedFile, coerce_with: ->(c) { ActionDispatch::Http::UploadedFile.new(c) },
               desc: '图片、视频或音频文件', documentation: {param_type: 'formData', type: 'File'}
      optional :information, type: String , desc: 'json string, 自定义信息, 如目标对象信息' 
      at_least_one_of :content, :file, desc: 'content参数和file至少有其一'
    end
    post :single do
      authenticate_user!
      msErr!('目标用户不存在或未注册', 1003) unless redis.hexists(u_list, params[:user_id])
      if s_list(params[:user_id]).include?(current_user['identifier'])
        msErr!('你已被此用户屏蔽', 1005)
      else
        original, preview = save_file(params[:file].tempfile.path) if params[:file]
        send_data = {
          session_type: 'single_chat',
          session_identifier: current_user['identifier'],
          session_icon: current_user['avatar'],
          session_title: current_user['name'],
          sender: sender,
          send_time: Time.now.to_i,
          content_type: params[:content_type],
          content: params[:content],
          content_file: original,
          content_preview: preview, 
          information: params[:information]
        }
        if push_data([params[:user_id]], send_data) == 0
          msReturn('', '用户不在线，消息已缓存')
        else
          msReturn('', 'OK')
        end
      end
    end

    desc '单聊,附件直传,需要严格依据返回参数上传附件', summary: '单聊,附件直传', tags: ['MESSAGES']
    params do
      requires :user_id, type: String, desc: '目标id'
      requires :content_type, type: String, desc: '消息类型'
      optional :content, type: String, desc: '消息中的文字内容'
      optional :file_name, type: String, desc: '要上传的文件名，包含后缀'
      optional :information, type: String , desc: 'json string, 自定义信息, 如目标对象信息' 
      at_least_one_of :content, :file_name, desc: 'content参数和file_name至少有其一'
    end
    post :single_sts do
      authenticate_user!
      msErr!('目标用户不存在或未注册', 1003) unless redis.hexists(u_list, params[:user_id])
      if s_list(params[:user_id]).include?(current_user['identifier'])
        msErr!('你已被此用户屏蔽', 1005)
      else 

        # 组织数据
        send_data = {
          session_type: 'single_chat',
          session_identifier: current_user['identifier'],
          session_icon: current_user['avatar'],
          session_title: current_user['name'],
          sender: sender,
          send_time: Time.now.to_i,
          content_type: params[:content_type],
          content: params[:content],
          content_file: nil,
          content_preview: nil, 
          information: params[:information]
        }

        if(params[:content_type].eql?('text') && params[:content].present?)   # 内容为纯文字时直接发给接收者
           push_data([params[:user_id]], send_data)

        elsif(params[:file_name].present?) # 内容为附件时把sts和callback发给接收者
          # 重命名，保留后缀
          a = current_user['identifier']  # => 发送者
          b = params[:user_id]            # => 接收者
          c = send_data[:send_time]       # => 发起时间
          d = UUIDTools::UUID.random_create.to_s.split('-')[0] # => 随机串
          file_name = "#{a}-#{b}-#{c}-#{d}#{File.extname(params[:file_name])}"
          send_data[:content_file] = "/msmi_file/original/#{file_name}"
          send_data[:content_preview] = "/msmi_file/preview/#{file_name}"
          hold_key = hold_data([params[:user_id]], send_data)
          msErr!('hold_data失败', 1008) if hold_key.nil?
          res = sts_token(file_name, hold_key)
          msErr!('sts_token获取失败', 1007) if res.nil?
        end
        msReturn(res||{})
      end
    end

    desc '发送消息到群，群聊', tags: ['MESSAGES'], summary: '群聊'
    params do
      requires :group_id, type: String, desc: '目标群id'
      requires :content_type, type: String, desc: '消息类型'
      optional :content, type: String, desc: '消息中的文字内容'
      optional :file, type: ActionDispatch::Http::UploadedFile, coerce_with: ->(c) { ActionDispatch::Http::UploadedFile.new(c) },
               desc: '图片、视频或音频文件', documentation: {param_type: 'formData', type: 'File'}
      optional :information, type: String, desc: 'json string, 自定义信息, 如目标对象信息' 
      at_least_one_of :content, :file, desc: 'content参数和file至少有其一'
    end
    post :group do
      authenticate_user!
      group_key = g_key(params[:group_id])
      msErr!('群不存在', 1003) unless redis.hexists(g_list, group_key)
      msErr!('不是群成员', 1003) if redis.zrank(group_key, current_user['identifier']).nil?
      group = group_info(current_user['app_id'], group_key)
      original, preview = save_file(params[:file].tempfile.path) if params[:file]
      send_data = {
        session_type: 'group_chat',
        session_identifier: params[:group_id],
        session_icon: group['group_icon'],
        session_title: group['group_name'],
        sender: sender,
        send_time: Time.now.to_i,
        content_type: params[:content_type],
        content: params[:content],
        content_file: original,
        content_preview: preview,
        information: params[:information]  
      }
      members = redis.zrange(group_key, 0, -1)
      members.delete(current_user['identifier'])
      push_data(members, send_data)
      msReturn('', 'OK')
    end

    desc '系统消息', tags: ['MESSAGES'], summary: '系统消息'
    params do
      requires :app_id, type: String, desc: '应用标识'
      requires :secret_key, type: String, desc: '应用密钥'
      
      requires :session_type, type: String, desc: '会话类型：应用(app_notifiction)、单聊(single_chat)、 群聊(group_chat)'
      requires :session_identifier, type: String, desc: '会话的唯一标识'
      optional :session_icon, type: String, desc: '会话的图标'
      optional :session_title, type: String, desc: '会话的标题'
      requires :action, type: String, desc: '操作类型'

      requires :sender_identifier, type: String, desc: '发起者的id'
      requires :sender_name, type: String, desc: '发起者的名字'
      requires :sender_avatar, type: String, desc: '发起者的头像'

      requires :time, type: Integer, desc: '发起动作的10位时间戳'

      requires :user_id, type: String, desc: '目标id'

      requires :content_type, type: String, desc: '消息类型'
      requires :content, type: String, desc: '消息中的文字内容'

      optional :information, type: String, desc: 'json string, 自定义信息, 如目标对象信息' 
    end
    post :system do
      authenticate_app!
      msErr!('目标用户不存在或未注册', 1002) unless redis.hexists(u_list, params[:user_id])
      msErr!('目标用户拒绝接收此类通知', 1003) unless redis.hget(u_setting_key(params[:user_id]), 'allow_notification').try(:to_bool) || true # 未设置此项，默认为true
      send_data = {
          session_type: params[:session_type],
          session_identifier: params[:session_identifier],
          session_icon: params[:session_icon] || '',
          session_title: params[:session_title] || '',
          sender: {
                    identifier: params[:sender_identifier],
                    name: params[:sender_name],
                    avatar: params[:sender_avatar]
                  },
          action: params[:action],
          send_time: params[:time],
          content_type: params[:content_type],
          content: params[:content],
          content_file: nil,
          content_preview: nil, 
          information: params[:information]
        }
      push_data([params[:user_id]], send_data)
      msReturn('', 'OK')
    end
  end
end
