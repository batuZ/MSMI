require './app/helpers/application_helper'

namespace :redis do
	include ApplicationHelper

	desc '后台启动redis'
	task :start => :environment do
		if system('redis-cli ping')
			puts 'redis 服务正在运行'	
		else
			system 'nohup redis-server &'
    	puts 'redis 服务启动成功'	
		end
	end

	desc '关闭redis服务'
	task :stop => :environment do
		system 'redis-cli shutdown'
		puts 'redis 服务已经停止'	
	end

	desc '检查redis状态'
	task :check => :environment do
		if system('redis-cli ping')
			puts 'redis 服务正在运行'	
		else
    	puts 'redis 服务没有启动'	
		end
	end

	desc "redis信息"
	task :info => :environment do
		pp redis.info
	end

	desc "查询key, ex: rails redis:keys key='abc*' "
	task :keys => :environment do
		key = ENV['key'] || '*'
		pp redis.keys(key).map{|k| "[#{redis.type(k)}]#{k}" }
	end

	desc "显示全部的app"
	task :apps => :environment do
		redis.hgetall('apps').each{|k,v| pp "-------- #{k} -------------"; pp JSON.parse v}
	end

	desc "显示指定key的value, ex: rails redis:get key='abc' "
	task :get => :environment do
		key = ENV['key'] || '*'
		res = nil
		if redis.type(key).eql?'hash'
			ha = {}
			redis.hgetall(key).each{|k,v| ha[k] = JSON.parse v}
			res = ha

		elsif  redis.type(key).eql?'zset'
			res = redis.zrange(key, 0, -1)

		elsif  redis.type(key).eql?'string'
			res = redis.get key

		elsif  redis.type(key).eql?'list'
			res = redis.lrange(key, 0, -1)

		elsif  redis.type(key).eql?'set'
			res = redis.smembers key
		end

		pp "ttl: #{redis.ttl(key)}"
		pp res
	end
end
