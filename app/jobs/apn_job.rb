class ApnJob < ApplicationJob
  queue_as :default
  include ApplicationHelper

  def perform(app_name, device_token, badge)
    _log.info '>>>>>>>>>>>>>>>>>>>>> 1'
    # 发送内容
    # https://developer.apple.com/documentation/usernotifications/setting_up_a_remote_notification_server/generating_a_remote_notification?language=objc
    data_body = {
        aps: { 
          badge: badge, 
          alert: '收到一条新消息',
          sound: "bingbong.aiff"
        },
        # ms_data: ms_data # 不承载信息，只作静态提示
      }.to_json

    data_header = {
        'apns-push-type' => 'alert',
        'apns-expiration' => 0,
        'apns-topic' => 'cn.mapplay.Mappy',
        'apns-priority' => 10,
      }

    return 'test env will not do this' if Rails.env.eql?'test'
    _log.info '>>>>>>>>>>>>>>>>>>>>> 2'

    # 返回错误处理
    # https://developer.apple.com/documentation/usernotifications/setting_up_a_remote_notification_server/handling_notification_responses_from_apns?language=objc
    client = apn_client app_name
    _log.info '>>>>>>>>>>>>>>>>>>>>> 8'

     # 异步请求
    request = client.prepare_request(:post, "/3/device/#{device_token}",  body: data_body, headers: data_header)
    _log.info '>>>>>>>>>>>>>>>>>>>>> 9'

    # request.on(:headers) { |headers| p headers }
    request.on(:body_chunk) { |chunk|  _log.info ">>>>>>>>>>>>>>>>>>>>> 12 #{chunk}" }
    request.on(:close) { _log.info '>>>>>>>>>>>>>>>>>>>>> 13' }
    client.call_async(request)
    _log.info '>>>>>>>>>>>>>>>>>>>>> 10'

    client.join
    _log.info '>>>>>>>>>>>>>>>>>>>>> 11'
    
    #同步请求
    # response = @@client.call(:post, "/3/device/#{device_token}",  body: data_body, headers: data_header)
    # response.ok?      # => true
    # response.status   # => '200'
    # response.headers  # => {":status"=>"200"}
    # response.body     # => "A body"
  end
end