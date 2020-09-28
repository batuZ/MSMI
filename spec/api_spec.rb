require 'rails_helper'

RSpec.describe 'API', type: :request do
	before :each do
		redis.flushdb
	end

	let(:app_name) {'mapplay_test'}
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

# ========================= USER =========================

  it '创建用户' do
 		create_app
  	post '/token', params: {
  		app_id: app_name,
  		secret_key: app_key,
  		identifier: 'ccc',
  		name: '工人',
  		avatar: 'http://image/ccc.jpg'
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
