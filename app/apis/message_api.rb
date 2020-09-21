class MessageAPI < Grape::API
	resources :message do

		desc '单聊', summary: '单聊'
		params do
			requires :user_id,	type: String,	desc: '目标id'
			requires :content,		type: String,	desc: '消息中的文字内容'
		end
		post :single do
			authenticate_user!
			send_to = "#{current_user['app_id']}:#{params[:user_id]}"
			send_data = {
				message_type: 'single',
				sender: {
					identifier: current_user['user_id'],
					name: current_user['user_name'],
					avatar:  current_user['avatar_url']
				},
				send_time: Time.now.to_i,
				content_type: 'text',
				content: params[:content],
				preview: ''
			}
			send_res = ActionCable.server.broadcast(send_to, send_data) 
			if send_res == 0
				hold = {send_to: send_to, send_data: send_data }
				redis.setex("#{Time.now.to_i}_#{send_to}", 1.hour.to_i, hold.to_json)
			end
			msReturn
		end

		desc '发送消息到群，群聊'
		params do
			requires :group_id,	type: String,	desc: '目标群id'
			requires :content,		type: String,	desc: '消息中的文字内容'
		end
		post :group do
			authenticate_user!
			msErr!('群不存在', 1003) unless redis.hexists("#{current_user['app_id']}:groups", params[:group_id])
			msErr!('不是群成员', 1003) if redis.zrank(params[:group_id], current_user['user_id']).nil?
			group = group_info(current_user['app_id'], params[:group_id])
			send_data = {
				message_type: 'group',
				session_id: params[:group_id],
				session_icon: group['group_icon'],
				session_title: group['group_name'],
				sender: {
					identifier: current_user['user_id'],
					name: current_user['user_name'],
					avatar:  current_user['avatar_url']
				},
				send_time: Time.now.to_i,
				content_type: 'text',
				content: params[:content],
				preview: ''
			}
			members = redis.zrange(params[:group_id], 0, -1)
			members.each do |m|
				send_to = "#{current_user['app_id']}:#{m}"
				send_res = ActionCable.server.broadcast(send_to, send_data) 
				if send_res == 0
					hold = {send_to: send_to, send_data: send_data }
					redis.setex("#{Time.now.to_i}_#{send_to}", 1.hour.to_i, hold.to_json)
				end
			end
		end
	end
end
