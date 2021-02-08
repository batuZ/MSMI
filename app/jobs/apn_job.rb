class ApnJob < ApplicationJob
  queue_as :default
  include ApplicationHelper

  def perform(app_name, device_token, badge)
    pem = "config/keys/apn/#{app_name}/product.pem"
    apn_host = "https://api.push.apple.com:443"

    unless  Rails.env.eql?('production')
      pem = "config/keys/apn/#{app_name}/sandbox.pem"
      apn_host = "https://api.sandbox.push.apple.com:443"
    end
    
    return(p 'no pem file') unless FileTest::exist?(pem)
    # 把p12转成pem
    # openssl pkcs12 -in aps_development.p12 -out ck_from_p12.pem -nodes
    # 验证pem握手成功
    # openssl s_client -connect api.development.push.apple.com:443 -cert "/Users/Batu/ck_from_p12.pem"
    certificate = File.read(pem)
    ctx         = OpenSSL::SSL::SSLContext.new
    ctx.key     = OpenSSL::PKey::RSA.new(certificate)
    ctx.cert    = OpenSSL::X509::Certificate.new(certificate)
    
    # net/http2 gem
    # https://developer.apple.com/documentation/usernotifications/setting_up_a_remote_notification_server/sending_notification_requests_to_apns?language=objc
    @@client ||= NetHttp2::Client.new(apn_host, ssl_context: ctx)
    # client = NetHttp2::Client.new("https://api.push.apple.com : 443", ssl_context: ctx)
    
    # 发送内容
    # https://developer.apple.com/documentation/usernotifications/setting_up_a_remote_notification_server/generating_a_remote_notification?language=objc
    request = @@client.prepare_request(:post, "/3/device/#{device_token}", 
      body: {
        aps: { 
          badge: badge, 
          alert: '收到一条新消息',
          sound: "bingbong.aiff"
        },
        # ms_data: ms_data # 不承载信息，只作静态提示
      }.to_json,
      headers: {
        'apns-push-type' => 'alert',
        'apns-expiration' => 0,
        'apns-topic' => 'cn.mapplay.Mappy',
        'apns-priority' => 10,
      })
  
    # 返回错误处理
    # https://developer.apple.com/documentation/usernotifications/setting_up_a_remote_notification_server/handling_notification_responses_from_apns?language=objc
    request.on(:headers) { |headers| p headers }
    request.on(:body_chunk) { |chunk|  p chunk }
    request.on(:close) { puts "request completed!" }

    return 'test env will not do this' if Rails.env.eql?'test'

    @@client.call_async(request)
    @@client.join
    # client.close
  end
end