class ApnPingJob < ApplicationJob
  queue_as :default
  include ApplicationHelper

  # 每小时瞎摸apn一下，证明还活着，矫情！
  def perform(app_name)
  	if Rails.p?
  		ApnPingJob.set(wait: 1.hour).perform_later(app_name)

	  	_log.info '>>>>>>>>>>>>>>>>>>>>> apn ping'
	  	notification       = Apnotic::Notification.new('ping token')
	    notification.alert = 'i am life'
	    notification.sound = "bingbong.aiff"

	    notification.expiration = 0
	    notification.topic = 'cn.mapplay.Mappy'
	    notification.priority = 10

	    client = apn_client1 app_name
	    push = client.prepare_push(notification)
	    push.on(:response) do |response|
	      _log.info ">>>>>>>>>>>>>>>>>>>>> ping back #{response.status}"
	    end

	    # send
	    client.push_async(push)
	    client.join(timeout: 5)
	    client.close
  	end
  end
end