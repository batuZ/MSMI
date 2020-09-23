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
		u = { app_id: 'mapplay_test', user_id: 'user_1', user_name: '用户1', avatar_url: 'http://image/1.jpg' }
		redis.hset "#{app_name}:users", u[:user_id], { user_name: u[:user_name], avatar_url: u[:avatar_url] }.to_json 
		JWT.encode(u, 'test_hash_key')
	}
	let(:token2){ 
		u = { app_id: app_name, user_id: 'user_2', user_name: '用户2', avatar_url: 'http://image/2.jpg' }
		redis.hset "#{app_name}:users", u[:user_id], { user_name: u[:user_name], avatar_url: u[:avatar_url] }.to_json 
		JWT.encode(u, 'test_hash_key')
	}
	let(:token3){ 
		u = { app_id: app_name, user_id: 'user_3', user_name: '用户3', avatar_url: 'http://image/3.jpg' }
		redis.hset "#{app_name}:users", u[:user_id], { user_name: u[:user_name], avatar_url: u[:avatar_url] }.to_json 
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
  		user_id: 'ccc',
  		user_name: '工人',
  		avatar_url: 'http://image/ccc.jpg'
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
  	___show _content
	end

# ========================= GROUP =========================

  it '创建群' do
  	create_app;token1;token2;token3
  	post '/create_group', params: {
  		group_name: '组a',
  		group_icon: 'https://wwww.group/1.jpg',
  		members: ['user_2','user_3']
  	 }, headers: { 'Msmi-Token' => token1 }
  	 expect(_code).to be == 1000
    # ___show _content
  end

  it '群成员列表' do
  	create_app;token1;token2;token3
  	post '/create_group', params: {
  		group_name: '组a',
  		group_icon: 'https://wwww.group/1.jpg',
  		members: ['user_2','user_3']
  	 	}, headers: { 'Msmi-Token' => token1 }
  	expect(_code).to be == 1000
  	groupid = _content
  	get '/members', params: {group_id: groupid}, headers: { 'Msmi-Token' => token1 }
  	expect(_code).to be == 1000
    # ___show _content
  end

  it '我加入的群' do
  	create_app;token1;token2;token3
  	post '/create_group', params: {
  		group_name: '组a',
  		group_icon: 'https://wwww.group/1.jpg',
  		members: ['user_2','user_3']
  	 	}, headers: { 'Msmi-Token' => token1 }
  	expect(_code).to be == 1000
  	groupid = _content
  	get '/groups', params:{group_id: groupid}, headers:{'Msmi-Token' => token1}
  	expect(_code).to be == 1000
  end


  it '添加成员' do
  	create_app;token1;token2;token3
  	post '/create_group', params: {
  		group_name: '组a',
  		group_icon: 'https://wwww.group/1.jpg',
  		members: ['user_2']}, headers: { 'Msmi-Token' => token1 }
		expect(_code).to be == 1000
		groupid = _content
		post '/members', params: {group_id: groupid, members: ['user_2', 'user_3']}, headers: { 'Msmi-Token' => token1 }
		expect(_code).to be == 1000
		# ___show _content
  end

  it '加入群' do
  	create_app;token1;token2;token3
  	post '/create_group', params: {
  		group_name: '组a',
  		group_icon: 'https://wwww.group/1.jpg',
  		members: ['user_2']}, headers: { 'Msmi-Token' => token1 }
		expect(_code).to be == 1000
		groupid = _content
		post '/join', params: {group_id: groupid}, headers:{'Msmi-Token' => token3}
		expect(_code).to be == 1000
  end

  it  '移除成员' do
  	create_app;token1;token2;token3
  	post '/create_group', params: {
  		group_name: '组a',
  		group_icon: 'https://wwww.group/1.jpg',
  		members: ['user_2','user_3']
  	 	}, headers: { 'Msmi-Token' => token1 }
  	expect(_code).to be == 1000
  	groupid = _content
  	delete '/members', params: {group_id: groupid, members: ['user_2']}, headers: { 'Msmi-Token' => token1 }
  	expect(_code).to be == 1000
    # ___show _content
  end

  it '退群' do
  	create_app;token1;token2;token3
  	post '/create_group', params: {
  		group_name: '组a',
  		group_icon: 'https://wwww.group/1.jpg',
  		members: ['user_2','user_3']
  	 	}, headers: { 'Msmi-Token' => token1 }
  	expect(_code).to be == 1000
  	groupid = _content
  	delete '/quit', params: {group_id: groupid}, headers: {'Msmi-Token' => token3}
  	expect(_code).to be == 1000
  end

  it '解散群' do
  	create_app;token1;token2;token3
  	post '/create_group', params: {
  		group_name: '组a',
  		group_icon: 'https://wwww.group/1.jpg',
  		members: ['user_2','user_3']
  	 	}, headers: { 'Msmi-Token' => token1 }
  	expect(_code).to be == 1000
  	groupid = _content
  	delete '/group', params: {group_id: groupid}, headers: {'Msmi-Token' => token1}
  	expect(_code).to be == 1000
  end
end
