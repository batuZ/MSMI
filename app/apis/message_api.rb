class MessageAPI < Grape::API
  resources :message do

    desc '单聊', summary: '单聊', tags: ['MESSAGES']
    params do
      requires :user_id, type: String, desc: '目标id'
      requires :content_type, type: String, desc: '消息类型'
      optional :content, type: String, desc: '消息中的文字内容'
      optional :file, type: ActionDispatch::Http::UploadedFile, coerce_with: ->(c) { ActionDispatch::Http::UploadedFile.new(c) },
               desc: '图片、视频或音频文件', documentation: {param_type: 'formData', type: 'File'}
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
          content_preview: preview
        }
        if push_data([params[:user_id]], send_data) == 0
          msReturn('', '用户不在线，消息已缓存')
        else
          msReturn('', 'OK')
        end
      end
    end

    desc '发送消息到群，群聊', tags: ['MESSAGES'], summary: '群聊'
    params do
      requires :group_id, type: String, desc: '目标群id'
      requires :content_type, type: String, desc: '消息类型'
      optional :content, type: String, desc: '消息中的文字内容'
      optional :file, type: ActionDispatch::Http::UploadedFile, coerce_with: ->(c) { ActionDispatch::Http::UploadedFile.new(c) },
               desc: '图片、视频或音频文件', documentation: {param_type: 'formData', type: 'File'}
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
        content_preview: preview
      }
      members = redis.zrange(group_key, 0, -1)
      members.delete(current_user['identifier'])
      push_data(members, send_data)
      msReturn('', 'OK')
    end
  end
end
