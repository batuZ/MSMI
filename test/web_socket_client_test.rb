# # https://github.com/imanel/websocket-eventmachine-client
require 'websocket'
require 'websocket-eventmachine-client'
require 'pp'
require 'json'

EM.run do
  ws = WebSocket::EventMachine::Client.connect(:uri => 'ws://127.0.0.1:3000/cable',headers: {msmi_token:  "eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoidXNlcl9pZCIsInVzZXJfbmFtZSI6InVzZXJfbmFtZSIsImF2YXRhcl91cmwiOiJhdmF0YXJfdXJsIiwiYXBwX2lkIjoibWFwcGxheSJ9.6p_6c53u5bC7RZEBPpQJPLOLSHh4PFUJCdmbxttY6uo"})
  
  ws.onopen do
    ws.send({ command: 'subscribe', identifier: {channel: 'OnlineChannel'}.to_json }.to_json)
  end

  ws.onmessage do |msg, type|
    json = JSON.parse(msg)
    if json["type"].nil?
      puts ">>>>>>>>>> Received message: #{json}" 
      msg = {
        command: 'message',
        identifier: { channel: 'OnlineChannel' }.to_json,
        data: {
          action: 'user_message',
          params: "收到消息: #{json}"
        }.to_json
      }.to_json
      ws.send msg
    end
  end

  ws.onclose do |code, reason|
    puts "Disconnected with status code: #{code}"
  end
  
  EventMachine.next_tick do
    # ws.send "Hello Server!"
  end

end

=begin
  
//  "{\"identifier\":\"{\\\"channel\\\":\\\"OnlineChannel\\\"}\",\"command\":\"subscribe\"}"

// 发送数据示例
 case data["command"]
 
 when "subscribe"   then add data
 data = {
 "command"=>"subscribe",
 "identifier"=>"{\"channel\":\"RoomChannel\"}"
 }
 
 when "unsubscribe" then remove data
 
 when "message"     then perform_action data
 data = @{
 "command"=>"message",
 "identifier"=>"{\"channel\":\"RoomChannel\"}",
 "data"=>"{\"msg\":\"客户端向服务器发送的消息。。。\",\"action\":\"print_log\"}"
 }
 
 NSDictionary* dic = @{@"command": @"subscribe",
 @"identifier": @"{\"channel\":\"RoomChannel\"}"};
 
 NSDictionary* dic = @{@"command": @"message",
 @"identifier": @{@"channel": channel},
 @"data": @{@"msg": @"客户端向服务器发送的消息。。。", @"params" : @"acd", @"action": @"print_log"}
 };
 
 NSString* jsonString = [self __deepStringWithDic:dic];
 [self sendDataToServer: jsonString];

=end