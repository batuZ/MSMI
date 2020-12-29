require 'rails_helper'

RSpec.describe 'API', type: :request do
	before :each do
		redis.flushdb
	end

	let(:app_name) {'mapplay'}
	let(:app_key){'abcdefg'}
	let(:create_app){ redis.hset 'apps', app_name, {
											create_time: Time.now.to_i,
											max_lenght: 1.year,
											max_users: 100,
											secret_key: app_key,
											ownner: '',
											email: ''}.to_json
										}
	let(:token1){ 
		u = { identifier: 'user_1', name: '用户1', avatar: 'http://image/1.jpg' }
		redis.hset "#{app_name}:users", u[:identifier], u.to_json 
    u[:app_id] = app_name
		JWT.encode(u, 'test_hash_key')
	}
	let(:token2){ 
		u = { identifier: 'user_2', name: '用户2', avatar: 'http://image/2.jpg' }
    redis.hset "#{app_name}:users", u[:identifier], u.to_json 
    u[:app_id] = app_name
    JWT.encode(u, 'test_hash_key')
	}
	let(:token3){ 
		u = { identifier: 'user_3', name: '用户3', avatar: 'http://image/3.jpg' }
    redis.hset "#{app_name}:users", u[:identifier], u.to_json 
    u[:app_id] = app_name
    JWT.encode(u, 'test_hash_key')
	}

# ========================= APP =========================

	it "创建app" do
    post '/app', params: {app: 'aaa'}
    expect(_code).to be == 1000
    # ___show _content
  end

# ========================= MESSAGE =========================
  it '单聊' do
    create_app;token1;token2;token3
    post '/message/single', params:{
      user_id: 'user_3', 
      content: 'asdf',
      content_type: 'image',
      file: fixture_file_upload('/Users/Batu/Pictures/katong_1/avatar_2.jpg','image/jpeg')
    }, headers:{'Msmi-Token' => token1}
    expect(_code).to be == 1000
    # ___show _content
  end

  it '群聊' do
    create_app;token1;token2;token3
    post '/group', params: {
      group_name: '组a',
      group_icon: 'https://wwww.group/1.jpg',
      members: ['user_2','user_3']
      }, headers: { 'Msmi-Token' => token1 }
    expect(_code).to be == 1000
    groupid = _content['new_group_id']

    post '/message/group', params:{group_id: groupid, content: 'asdf', content_type: 'text'}, headers:{'Msmi-Token' => token1}
     expect(_code).to be == 1000
    # ___show _content
  end
# ========================= USER =========================

  it '创建用户' do
 		create_app
  	post '/token', params: {
  		app_id: app_name,
  		secret_key: app_key,
  		identifier: 'ccc',
  		name: '工人',
  		avatar: 'http://image/ccc.jpg',
      device_token: '1dbb681345249d2c7e1c74d8321fcda4f5d2fe694d7cd6255514ff3381ddb0b7',
      os_type: 1
  	}
  	expect(_code).to be == 1000
    # ___show _content
  end

  it '添加好友' do 
  	create_app;token1;token2;token3
  	post '/friends', params: {user_id: 'user_3'}, headers:{'Msmi-Token' => token1}
  	expect(_code).to be == 1000
  	post '/friends', params: {user_id: 'user_2'}, headers:{'Msmi-Token' => token1}
  	expect(_code).to be == 1000
  	# ___show _content
  end

  it '设置approve， 加好友， 审批好友审请' do
    create_app;token1;token2;token3
    post '/user_setting',  params: {approve: 1}, headers:{'Msmi-Token' => token1}
    expect(_code).to be == 1000 # 设置approve
    post '/friends', params: {user_id: 'user_1'}, headers:{'Msmi-Token' => token3}
    expect(_code).to be == 1000 # 加好友
    post '/judgment',  params: {user_id: 'user_3', judgment: true}, headers:{'Msmi-Token' => token1}
    expect(_code).to be == 1000 # 审批好友审请
    # ___show _content
  end

  it '删除好友' do
  	create_app;token1;token2;token3
  	post '/friends', params: {user_id: 'user_3'}, headers:{'Msmi-Token' => token1}
  	post '/friends', params: {user_id: 'user_2'}, headers:{'Msmi-Token' => token1}
  	delete '/friends', params: {user_id: 'user_3'}, headers:{'Msmi-Token' => token1}
  	expect(_code).to be == 1000
  	# ___show _content
  end

  it '获取好友列表' do
  	create_app;token1;token2;token3
  	post '/friends', params: {user_id: 'user_3'}, headers:{'Msmi-Token' => token1}
  	post '/friends', params: {user_id: 'user_2'}, headers:{'Msmi-Token' => token1}
  	get '/friends', headers:{'Msmi-Token' => token1}
  	expect(_code).to be == 1000
  	# ___show _content
  end

  it '增加屏蔽用户' do
  	create_app;token1;token2;token3
  	post '/shield', params: {user_id: 'user_3'}, headers:{'Msmi-Token' => token1}
  	expect(_code).to be == 1000
  	# ___show _content
  end

	it '删除屏蔽用户' do
		create_app;token1;token2;token3
		post '/shield', params: {user_id: 'user_3'}, headers:{'Msmi-Token' => token1}
		post '/shield', params: {user_id: 'user_2'}, headers:{'Msmi-Token' => token1}
		delete '/shield', params: {user_id: 'user_3'}, headers:{'Msmi-Token' => token1}
		expect(_code).to be == 1000
  	# ___show _content
	end

	it '获取屏蔽列表' do
		create_app;token1;token2;token3
		post '/shield', params: {user_id: 'user_3'}, headers:{'Msmi-Token' => token1}
		post '/shield', params: {user_id: 'user_2'}, headers:{'Msmi-Token' => token1}
		get '/shield', headers:{'Msmi-Token' => token1}
		expect(_code).to be == 1000
  	# ___show _content
	end

# ========================= GROUP =========================

  it '创建群' do
  	create_app;token1;token2;token3
  	post '/group', params: {
  		group_name: '组a',
  		group_icon: 'https://wwww.group/1.jpg',
  		members: ['user_2','user_3']
  	 }, headers: { 'Msmi-Token' => token1 }
  	 expect(_code).to be == 1000
    # ___show _content
  end

  it '群成员列表' do
  	create_app;token1;token2;token3
  	post '/group', params: {
  		group_name: '组a',
  		group_icon: 'https://wwww.group/1.jpg',
  		members: ['user_2','user_3']
  	 	}, headers: { 'Msmi-Token' => token1 }
  	expect(_code).to be == 1000
  	groupid = _content['new_group_id']
  	get '/members', params: {group_id: groupid}, headers: { 'Msmi-Token' => token1 }
  	expect(_code).to be == 1000
    # ___show _content
  end

  it '我的群列表' do
  	create_app;token1;token2;token3
  	post '/group', params: {
  		group_name: '组a',
  		group_icon: 'https://wwww.group/1.jpg',
  		members: ['user_2','user_3']
  	 	}, headers: { 'Msmi-Token' => token1 }
    expect(_code).to be == 1000
    post '/group', params: {
      group_name: '组b',
      group_icon: 'https://wwww.group/1.jpg',
      members: ['user_3']
      }, headers: { 'Msmi-Token' => token1 }
    expect(_code).to be == 1000
    post '/group', params: {
      group_name: '组b',
      group_icon: 'https://wwww.group/1.jpg',
      members: []
      }, headers: { 'Msmi-Token' => token1 }
  	expect(_code).to be == 1000
  	get '/groups', headers:{'Msmi-Token' => token1}
  	expect(_code).to be == 1000
    # ___show _content
  end

  it '群设置, 加群， 审批' do
    create_app;token1;token2;token3
    post '/group', params: {
      group_name: '组a',
      group_icon: 'https://wwww.group/1.jpg',
      members: ['user_2']}, headers: { 'Msmi-Token' => token1 }
    expect(_code).to be == 1000
    groupid = _content['new_group_id']
    post '/group_setting', params: {group_id: groupid, approve: 1}, headers: { 'Msmi-Token' => token1 }
    expect(_code).to be == 1000
    post '/join', params: {group_id: groupid, remark: '123'}, headers:{'Msmi-Token' => token3}
    expect(_code).to be == 1000
    post '/group_judgment', params: {group_id: groupid, user_id: 'user_3', judgment: false}, headers:{'Msmi-Token' => token1}
    expect(_code).to be == 1000
    # ___show _content
  end

  it '添加成员' do
  	create_app;token1;token2;token3
  	post '/group', params: {
  		group_name: '组a',
  		group_icon: 'https://wwww.group/1.jpg',
  		members: ['user_2']}, headers: { 'Msmi-Token' => token1 }
		expect(_code).to be == 1000
		groupid = _content['new_group_id']
		post '/members', params: {group_id: groupid, members: ['user_2', 'user_3']}, headers: { 'Msmi-Token' => token1 }
		expect(_code).to be == 1000
		# ___show _content
  end

  it '加入群' do
  	create_app;token1;token2;token3
  	post '/group', params: {
  		group_name: '组a',
  		group_icon: 'https://wwww.group/1.jpg',
  		members: ['user_2']}, headers: { 'Msmi-Token' => token1 }
		expect(_code).to be == 1000
		groupid = _content['new_group_id']
		post '/join', params: {group_id: groupid}, headers:{'Msmi-Token' => token3}
		expect(_code).to be == 1000
  end

  it  '移除成员' do
  	create_app;token1;token2;token3
  	post '/group', params: {
  		group_name: '组a',
  		group_icon: 'https://wwww.group/1.jpg',
  		members: ['user_2','user_3']
  	 	}, headers: { 'Msmi-Token' => token1 }
  	expect(_code).to be == 1000
  	groupid = _content['new_group_id']
  	delete '/members', params: {group_id: groupid, members: ['user_2']}, headers: { 'Msmi-Token' => token1 }
  	expect(_code).to be == 1000
    # ___show _content
  end

  it '退群' do
  	create_app;token1;token2;token3
  	post '/group', params: {
  		group_name: '组a',
  		group_icon: 'https://wwww.group/1.jpg',
  		members: ['user_2','user_3']
  	 	}, headers: { 'Msmi-Token' => token1 }
  	expect(_code).to be == 1000
  	groupid = _content['new_group_id']
  	delete '/quit', params: {group_id: groupid}, headers: {'Msmi-Token' => token3}
  	expect(_code).to be == 1000
  end

  it '解散群' do
  	create_app;token1;token2;token3
  	post '/group', params: {
  		group_name: '组a',
  		group_icon: 'https://wwww.group/1.jpg',
  		members: ['user_2','user_3']
  	 	}, headers: { 'Msmi-Token' => token1 }
  	expect(_code).to be == 1000
  	groupid = _content['new_group_id']
  	delete '/group', params: {group_id: groupid}, headers: {'Msmi-Token' => token1}
  	expect(_code).to be == 1000
  end
end
