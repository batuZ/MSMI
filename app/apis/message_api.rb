class MessageAPI < Grape::API
	resources :message do

		desc '单聊', summary: '单聊'
		params do
			requires :user_id,	type: String,	desc: '目标id'
			requires :content,		type: String,	desc: '消息中的文字内容'
		end
		post :single do
			authenticate_user!
			msErr!('目标用户不存在或未注册', 1003) unless redis.hexists(u_list, params[:user_id])
			if s_list(params[:user_id]).include?(current_user['identifier'])
				msReturn('','你已被此用户屏蔽')
			else
				send_data = {
					session_type: 'single_chat',
					session_identifier: current_user['identifier'],
					session_icon: current_user['avatar'],
					session_title: current_user['name'],
					sender: sender,
					send_time: Time.now.to_i,
					content_type: 'text',
					content: params[:content],
					preview: ''
				}
				send_to = u_key(params[:user_id])
				if ActionCable.server.broadcast(send_to, send_data) == 0
					hold = {send_to: send_to, send_data: send_data }
					redis.setex("#{send_to}:messages:#{Time.now.to_i}", 1.hour.to_i, hold.to_json)
					msReturn('', '用户不在线，消息已缓存')
				else
					msReturn('','OK')
				end
			end
		end


		desc '发送消息到群，群聊'
		params do
			requires :group_id,	type: String,	desc: '目标群id'
			requires :content,		type: String,	desc: '消息中的文字内容'
		end
		post :group do
			authenticate_user!
			group_key = g_key(params[:group_id])
			msErr!('群不存在', 1003) unless redis.hexists(g_list, group_key)
			msErr!('不是群成员', 1003) if redis.zrank(group_key, current_user['identifier']).nil?
			group = group_info(current_user['app_id'], group_key)
			send_data = {
				session_type: 'group_chat',
				session_identifier: params[:group_id],
				session_icon: group['group_icon'],
				session_title: group['group_name'],
				sender: sender,
				send_time: Time.now.to_i,
				content_type: 'text',
				content: params[:content],
				preview: ''
			}
			members = redis.zrange(group_key, 0, -1)
			members.delete(current_user['identifier'])
			members.each do |m|
				unless s_list(m).include?(current_user['identifier'])
					send_to = u_key(m)
					send_res = ActionCable.server.broadcast(send_to, send_data) 
					if send_res == 0
						hold = {send_to: send_to, send_data: send_data }
						redis.setex("#{send_to}:messages:#{Time.now.to_i}", 1.hour.to_i, hold.to_json)
					end
				end
			end
			msReturn('','OK')
		end
	end
end
