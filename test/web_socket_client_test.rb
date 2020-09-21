# # https://github.com/imanel/websocket-eventmachine-client
require 'websocket'
require 'websocket-eventmachine-client'
require 'pp'
require 'json'

建国 = {
  user_id: 'Daogelasi_JianGuo',
  user_name: '道格拉斯·建国',
  avatar_url: 'https://images.12306.com/avatar/img_3617.jpg',
  app_id: 'mapplay'
} 

淑芬 = {
  user_id: 'Nigulash_ShuFen',
  user_name: '尼古拉斯·淑芬',
  avatar_url: 'https://images.12306.com/avatar/img_9983.jpg',
  app_id: 'mapplay'
} 

铁蛋 = {
  user_id: 'Aixinjueluo_TieDan',
  user_name: '爱新觉罗·铁蛋',
  avatar_url: 'https://images.12306.com/avatar/img_1777.jpg',
  app_id: 'mapplay'
} 

jg_token = 'eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoiRGFvZ2VsYXNpX0ppYW5HdW8iLCJ1c2VyX25hbWUiOiLpgZPmoLzmi4nmlq_Ct-W7uuWbvSIsImF2YXRhcl91cmwiOiJodHRwczovL2ltYWdlcy4xMjMwNi5jb20vYXZhdGFyL2ltZ18zNjE3LmpwZyIsImFwcF9pZCI6Im1hcHBsYXkifQ.iomZBi4svVOwjhGpm2sl7se2ULKzCPF5KKfqkVdpKlk'
sf_token = 'eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoiTmlndWxhc2hfU2h1RmVuIiwidXNlcl9uYW1lIjoi5bC85Y-k5ouJ5pavwrfmt5HoiqwiLCJhdmF0YXJfdXJsIjoiaHR0cHM6Ly9pbWFnZXMuMTIzMDYuY29tL2F2YXRhci9pbWdfOTk4My5qcGciLCJhcHBfaWQiOiJtYXBwbGF5In0.lM8Jh9ntpgbWWCaTJKsuaMYQC7spfUbJ_FWtFg5Euvs'
td_token = 'eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoiQWl4aW5qdWVsdW9fVGllRGFuIiwidXNlcl9uYW1lIjoi54ix5paw6KeJ572Xwrfpk4Hom4siLCJhdmF0YXJfdXJsIjoiaHR0cHM6Ly9pbWFnZXMuMTIzMDYuY29tL2F2YXRhci9pbWdfMTc3Ny5qcGciLCJhcHBfaWQiOiJtYXBwbGF5In0.hJNrzLuaLNq6gw72ahjQIaO1soE4xrbYHWKkTPRT90M'

EM.run do
  ws = WebSocket::EventMachine::Client.connect(:uri => 'ws://39.107.250.142:3000/cable',headers: {msmi_token:  jg_token})
  
  ws.onopen do
    ws.send({ command: 'subscribe', identifier: {channel: 'OnlineChannel'}.to_json }.to_json)
  end

  ws.onmessage do |msg, type|
    json = JSON.parse(msg)
    if json["type"].nil?
      puts "#{json['message']['sender_name']}->铁蛋: #{json['message']['content']}"
    end
  end

  ws.onclose do |code, reason|
    puts "Disconnected with status code: #{code}"
  end
  
  EventMachine.next_tick do
    # ws.send "Hello Server!"
    # puts '输入：'
    # inp = gets.chomp
    # puts inp
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