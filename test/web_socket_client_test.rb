# # https://github.com/imanel/websocket-eventmachine-client
require 'websocket'
require 'websocket-eventmachine-client'
require 'pp'
require 'json'

user = {
  user_id: 'Daogelasi_JianGuo',
  user_name: '道格拉斯·建国',
  avatar_url: 'https://images.12306.com/avatar/img_3617.jpg',
  app_id: 'mapplay',
  token: 'eyJhbGciOiJIUzI1NiJ9.eyJpZGVudGlmaWVyIjoiRGFvZ2VsYXNpX0ppYW5HdW8iLCJuYW1lIjoi6YGT5qC85ouJ5pavwrflu7rlm70iLCJhdmF0YXIiOiJodHRwczovL2ltYWdlcy4xMjMwNi5jb20vYXZhdGFyL2ltZ18zNjE3LmpwZyIsImFwcF9pZCI6Im1hcHBsYXkifQ.3jgZIKdd6Xst-F7u0ZAN0Wx_i9MzDywYbSJU9dCSiaw'
}

# user = {
#   user_id: 'Nigulash_ShuFen',
#   user_name: '尼古拉斯·淑芬',
#   avatar_url: 'https://images.12306.com/avatar/img_9983.jpg',
#   app_id: 'mapplay',
#   token: 'eyJhbGciOiJIUzI1NiJ9.eyJpZGVudGlmaWVyIjoiTmlndWxhc2hfU2h1RmVuIiwibmFtZSI6IuWwvOWPpOaLieaWr8K35reR6IqsIiwiYXZhdGFyIjoiaHR0cHM6Ly9pbWFnZXMuMTIzMDYuY29tL2F2YXRhci9pbWdfOTk4My5qcGciLCJhcHBfaWQiOiJtYXBwbGF5In0.Sb9jexLCx90vCf4lDKb2_ZF4hoT9je89la_btMmi8Sw'
# }

# user = {
#   user_id: 'Aixinjueluo_TieDan',
#   user_name: '爱新觉罗·铁蛋',
#   avatar_url: 'https://images.12306.com/avatar/img_1777.jpg',
#   app_id: 'mapplay',
#   token: 'eyJhbGciOiJIUzI1NiJ9.eyJpZGVudGlmaWVyIjoiQWl4aW5qdWVsdW9fVGllRGFuIiwibmFtZSI6IueIseaWsOiniee9l8K36ZOB6JuLIiwiYXZhdGFyIjoiaHR0cHM6Ly9pbWFnZXMuMTIzMDYuY29tL2F2YXRhci9pbWdfMTc3Ny5qcGciLCJhcHBfaWQiOiJtYXBwbGF5In0.MfIWrWnfJj-xEwBvQjKZTpCk_rcWU1kTNnCa1lfrS74'
# } 

EM.run do
  # ws = WebSocket::EventMachine::Client.connect(:uri => 'wss://www.mapplay.cn:3334/cable',headers: {'msmi-token' =>  user[:token]})
  ws = WebSocket::EventMachine::Client.connect(:uri => 'ws://127.0.0.1:3000/cable',headers: {'msmi-token' =>  user[:token]})
  
  ws.onopen do
    ws.send({ command: 'subscribe', identifier: {channel: 'OnlineChannel'}.to_json }.to_json)
  end

  ws.onmessage do |msg, type|
    json = JSON.parse(msg)
    if json["type"].nil?
      puts "#{json['message']['sender']['name']}: #{json['message']['content']}"
    end
  end

  ws.onclose do |code, reason|
    puts "Disconnected with status code: #{code}"
  end
  
  EventMachine.next_tick do
    # ws.send "Hello Server!"
    # puts cu.first
    # inp = gets.chomp
    puts user[:user_name]
  end
end

=begin
//  "{\"identifier\":\"{\\\"channel\\\":\\\"OnlineChannel\\\"}\",\"command\":\"subscribe\"}"

 #   msg = {
    #     command: 'message',
    #     identifier: { channel: 'OnlineChannel' }.to_json,
    #     data: {
    #       action: 'user_message',
    #       params: "收到消息: #{json}"
    #     }.to_json
    #   }.to_json
    #   ws.send msg

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