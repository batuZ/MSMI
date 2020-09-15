class OnlineChannel < ApplicationCable::Channel
  
	# 用户登录频道，
  def subscribed
    stream_from "#{current_user['app_id']}_#{current_user['user_id']}_online"
    puts ">>>>>>> #{current_user['user_name']} 订阅后台通知成功"

    # 向客户端发送离线动态通知 
    unsend = redis_msg.keys("*_#{current_user['app_id']}_#{current_user['user_id']}_online").sort
    if(unsend.count > 0)
      puts ">>> 有 #{unsend.count} 条离线通知待发送。。。"
      unsend.each do |key|
        hold = JSON.parse(redis_msg.get(key))
        s = ActionCable.server.broadcast(hold['send_to'], hold['send_data'])
        redis_msg.del(key) if s == 1
      end
    end
  end

  def unsubscribed
    # 修改下线记录
    puts ">>> #{current_user['user_name']} 离线"
  end

  # 接收用户消息
  def user_receipt(data)
    pp "----->>>>> #{data['params']}"
  end

end