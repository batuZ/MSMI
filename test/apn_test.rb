require 'net-http2'
require 'json'
require 'apnotic'

def send_apn
  pem = "../config/keys/apn/dongting/sandbox.pem"
  apn_host = "https://api.sandbox.push.apple.com:443"

  certificate = File.read(pem)
  ctx         = OpenSSL::SSL::SSLContext.new
  ctx.key     = OpenSSL::PKey::RSA.new(certificate)
  ctx.cert    = OpenSSL::X509::Certificate.new(certificate)

  client = NetHttp2::Client.new(apn_host, ssl_context: ctx)

  data_body = {
        aps: { 
          badge: 1, 
          alert: '收到一条新消息',
          sound: "bingbong.aiff"
        },
        # ms_data: ms_data # 不承载信息，只作静态提示
      }.to_json

    data_header = {
        # 'apns-push-type' => 'alert',
        # 'apns-expiration' => 0,
        # 'apns-topic' => 'cn.mapplay.Mappy',
        # 'apns-priority' => 10,
      }
  response = client.call(:post, "/3/device/99f91f1a745935a16844674e2de4c26ab05da5b770421499c1899e618de9950f",  body: data_body, headers: data_header)
  p "is_ok: #{response.ok?}"
  p "status: #{response.status}"
  p "headers: #{response.headers}" 
  p "body: #{response.body}"
end

# send_apn
def tool
	# create a persistent connection
	connection = Apnotic::Connection.new(url: "https://api.sandbox.push.apple.com:443", cert_path: "../config/keys/apn/dongting/product.pem")
	connection.on(:error) { |exception| puts "Exception has been raised: #{exception}" }

	# create a notification for a specific device token
	token = "99f91f1a745935a16844674e2de4c26ab05da5b770421499c1899e618de9950f"

	notification       = Apnotic::Notification.new(token)

	notification.badge = 1
	notification.alert = "Notification from Apnotic!"
	notification.sound = "bingbong.aiff"

	notification.expiration = 0
	notification.topic = 'cn.mapplay.Mappy'
	notification.priority = 10

	# prepare push
	push = connection.prepare_push(notification)
	push.on(:response) do |response|
	  # read the response
		if response.status == '410' || (response.status == '400' && response.body['reason'] == 'BadDeviceToken')
	    # Device.find_by(token: token).destroy
	 	end
	end

	# send
	connection.push_async(push)

	# wait for all requests to be completed
	connection.join(timeout: 5)

	# close the connection
	connection.close
end

tool