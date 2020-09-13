# # https://github.com/imanel/websocket-eventmachine-client
require 'websocket'
require 'websocket-eventmachine-client'
require 'pp'
require 'json'
EM.run do
  ws = WebSocket::EventMachine::Client.connect(:uri => 'ws://127.0.0.1:3000/cable',headers: {msmi_token:  "eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoidXNlcl9pZCIsInVzZXJfbmFtZSI6InVzZXJfbmFtZSIsImF2YXRhcl91cmwiOiJhdmF0YXJfdXJsIiwiYXBwX2lkIjoibWFwcGxheSJ9.6p_6c53u5bC7RZEBPpQJPLOLSHh4PFUJCdmbxttY6uo"})
  ws.onopen do
    ws.send "{\"identifier\":\"{\\\"channel\\\":\\\"OnlineChannel\\\"}\",\"command\":\"subscribe\"}"
  end
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