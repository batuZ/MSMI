# MSMI

基于Rails\Grape\Redis的轻量即时通讯服务器

#### 特征:

* 无数关系据库

* API发送，WebSocket接收

* 离线消息、通知补发

* Rails web管理后台

#### API文档:

* 只能在开发环境访问
	```
	get: 127.0.0.1:3000/doc
	``` 

#### 流程：

* 通过api创建应用组[管理员]
	```
	post: 127.0.0.1:3000/app?app_name=APP_NAME # 获取id key
	``` 

* 通过api创建用户token[管理员]
	```
	post: 127.0.0.1:3000/user/token?user_id=Identifier&user_name=Tom&avatar_url=https:xxx.xxx.com/xx.jpg&app_id=APP_NAME
	```

* 通过api发送消息[用户]
	```
	post: 127.0.0.1:3000/message?tag_id=Identifier&text=message
	```
### 客户端示例
### [Android client demo](https://github.com/batuZ/MSMI_Client)
### [IOS client demo]()

#### 配置服务：
	
> 在`config/storage.yml`中配置聊天附件存储方式

> 在`config/cable.yml`中配置redis服务


TODO:

* manager pages
* notifications
* export & import
* initRediss
