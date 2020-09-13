module ApplicationCable
  class Connection < ActionCable::Connection::Base
  	include ApplicationHelper
  	identified_by :current_user
  	def connect 
  		authenticate_user env['HTTP_MSMI_TOKEN']
      self.current_user = current_user || reject_unauthorized_connection
    end
  end
end
