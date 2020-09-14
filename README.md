# MSMI

基于Rails\Grape\Redis的轻量即时通讯服务器

特征:

* 无数关系据库

* API发送，WebSocket接收

* 离线消息、通知补发

* Rails web管理后台


流程：

* 通过api创建应用组[管理员]
	```ruby
	post: 127.0.0.1:3000/app?app_name=APP_NAME
	``` 

* 通过api创建用户token[管理员]
	```ruby
	post: 127.0.0.1:3000/user/token?user_id=Identifier&user_name=Tom&avatar_url=https:xxx.xxx.com/xx.jpg&app_id=APP_NAME
	```

* 通过api发送消息[用户]
	```ruby
	post: 127.0.0.1:3000/message?tag_id=Identifier&text=message
	```

* wedsocket
	```ruby
	参考：https://github.com/imanel/websocket-eventmachine-client
	
	require 'websocket'
	require 'websocket-eventmachine-client'
	require 'pp'
	require 'json'
	EM.run do
		# 建立连接,并验证user_token
	  ws = WebSocket::EventMachine::Client.connect(:uri => 'ws://127.0.0.1:3000/cable',headers: {msmi_token:  "user_token"})
	  
	  # 订阅用户上线频道
	  ws.onopen do
	    ws.send "{\"identifier\":\"{\\\"channel\\\":\\\"OnlineChannel\\\"}\",\"command\":\"subscribe\"}"
	  end
	  # 接收消息的 callback
	  ws.onmessage do |msg, type|
	    json = JSON.parse(msg)
	    puts ">>>>>>>>>> Received message: #{json}" unless json["type"].eql?('ping')
	  end
	  ws.onclose do |code, reason|
	    puts "Disconnected with status code: #{code}"
	  end
	  EventMachine.next_tick do
	  	ss =  {user_message: "Hello Server!"}
	    ws.send ss
	  end
	end
```

