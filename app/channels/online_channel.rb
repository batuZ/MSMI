class OnlineChannel < ApplicationCable::Channel
  
	# 用户登录频道 # 当用户成为此频道的订阅者时调用
  def subscribed
    stop_all_streams
    stream_from u_key
    puts ">>>>>>> #{current_user['name']} 订阅后台通知成功, 当前频道streams：#{streams.map(&:first)}"

    # 向客户端发送离线动态通知 
    # unsend = redis.keys("*_#{u_key}").sort
    unsend = redis.keys("#{u_key}:messages:*").sort
    if(unsend.count > 0)
      puts ">>> 有 #{unsend.count} 条离线通知待发送。。。"
      unsend.each do |key|
        hold = JSON.parse(redis.get(key))
        s = ActionCable.server.broadcast(hold['send_to'], hold['send_data'])
        redis.del(key) if s == 1
      end
    end
  end

  def unsubscribed
    # 修改下线记录
    puts ">>>>>>> #{current_user['name']} 离线"
    stop_all_streams
  end

  # 接收用户消息
  def user_receipt(data)
    pp "----->>>>> #{data['params']}"
  end

end