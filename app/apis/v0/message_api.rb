module V0
	class MessageAPI < Grape::API
		resources :message do

			desc '发送一条消息', summary: '发送一条消息'
			params do
				requires :tag_id,	type: String,	desc: '目标id'
				requires :text,		type: String,	desc: '消息中的文字内容'
			end
			post do
				byebug
				ActionCable.server.broadcast(params[:tag_id]+'_online', params[:text])
				# => ActionCable.server.connections.first.connection_identifier
				# => ActionCable.server.connections.first.current_user
			end
		end
	end
end