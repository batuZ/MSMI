require "redis"
require 'json'
require 'byebug'

def redis
	@redis ||= Redis.new(driver: :hiredis, host: "127.0.0.1", port: 6379, db: 1)
end

def get_content keys
	byebug
	res = {}
	keys.each do |key|
		if redis.type(key).eql?'hash'
			ha = {}
			redis.hgetall(key).each{|k,v| ha[k] = JSON.parse v}
			res[key] = ha
		elsif  redis.type(key).eql?'zset'
			res[key] = redis.zrange(key, 0, -1)
		else
			res[key] = get_content(redis.keys "#{key}:*")
		end
	end
	res
end

def kkk str='*'
	# keys = redis.keys(str) > 拆分 > 获取第一部份 > 去重
	keys = redis.keys(str).map{|k|k.split(':').first}.uniq
	get_content keys
end

def sss str
	if(redis.hexists('apps', str))
		# keys = redis.keys(str << ':*').map{|k|k.split(':')[0]}.uniq
		iii str
	end
end

def iii str
	res = {}
	# 先判断当前key是否有内容, 有内容的直接塞到当前key里
	if(redis.type(str).eql?'hash')
		ha = {}
		redis.hgetall(key).each{|k,v| ha[k] = JSON.parse v}
		res[key] = ha
	elsif(redis.type(key).eql?'zset')
		res[key] = redis.zrange(key, 0, -1)

	elsif(redis.type(key).eql?'none') # 是结构的一部份，需要递归，从mapplay到mapplay:user
		str_arr = str.split(':')
		keys = redis.keys(str << ':*').map{|k|k.split(':')-str_arr}.compact.uniq # => mapplay:*
		keys.each do |skey|
			res[key] = iii('mapplay:user')
		end
		res[key] = iii('mapplay:user')
	end
	return res
end
redis.del 'aaa'
redis.sadd 'aaa', 'ss'
pp redis.type 'aaa'
pp redis.ttl 'aaa'


