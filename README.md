# MSMI

基于Rails\Grape\Redis的轻量即时通讯服务器

#### 特征:

* 无数关系据库

* API发送，WebSocket接收

* 离线消息、通知补发

* Rails web管理后台

#### API文档:

* 只能在开发环境访问
	```ruby
	get: 127.0.0.1:3000/doc # 只能在开发环境访问
	``` 

#### 流程：

* 通过api创建应用组[管理员]
	```ruby
	post: 127.0.0.1:3000/app?app_name=APP_NAME # 获取id key
	``` 

* 通过api创建用户token[管理员]
	```ruby
	post: 127.0.0.1:3000/user/token?user_id=Identifier&user_name=Tom&avatar_url=https:xxx.xxx.com/xx.jpg&app_id=APP_NAME
	```

* 通过api发送消息[用户]
	```ruby
	post: 127.0.0.1:3000/message?tag_id=Identifier&text=message
	```

### Android client demo: 
	https://github.com/batuZ/MSMI_Client


TODO:

* manager pages
* notifications
