module ApplicationCable
  class Connection < ActionCable::Connection::Base
  	include ApplicationHelper
  	identified_by :current_user
  	def connect 
  		authenticate_user env['HTTP_MSMI_TOKEN']
  		# puts current_user['name'] + '连接已存在' if ActionCable.server.connections.map(&:current_user).include?(current_user)
      self.current_user = current_user || reject_unauthorized_connection
      puts  ">>>>>>>>>>>>> #{self.current_user['name']} 通过了身份验证，已连接数#{ActionCable.server.connections.map(&:current_user).select{|s|s==current_user}.count+1}" if current_user
    end
  end
end
