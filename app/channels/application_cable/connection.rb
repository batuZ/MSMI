module ApplicationCable
  class Connection < ActionCable::Connection::Base
  	identified_by :current_user
  	def connect 
  		# 验证身份，找不到用户，不能创建socket
  		# 把头里的mstoken拿出来转成user,通过current_user对连接identified赋值
      self.current_user = [env['HTTP_CONNECT_TOKEN'],'haha']
    end
  end
end
