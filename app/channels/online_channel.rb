class OnlineChannel < ApplicationCable::Channel
	# 用户动态属性通知频道
  def subscribed
    stream_from "#{current_user}_online"
    puts ">>>>>>> #{current_user} 订阅后台通知成功"
  end

  def unsubscribed
    # 修改下线记录
    puts ">>> #{current_user} 离线"
  end

  # 接收用户消息
  def user_message(data)
  end
end