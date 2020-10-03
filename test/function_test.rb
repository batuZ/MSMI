# ============================= benchmark  性能测试  =============================
# https://ruby-doc.org//stdlib-2.2.2/libdoc/benchmark/rdoc/Benchmark.html
# https://www.qiuzhi99.com/articles/ruby-xing-neng-ce-shi
require 'benchmark'
require 'benchmark/ips'
include Benchmark

hs = {'a' => 123}
pp hs[:a]
pp hs['a']

# pp aa.downcase.delete
# n = 5000000
# Benchmark.benchmark(CAPTION, 7, FORMAT, ">total:", ">avg:") do |x|
#   tf = x.report("for:")   { for i in 1..n; a = "1"; end }
#   tt = x.report("times:") { n.times do   ; a = "1"; end }
#   tu = x.report("upto:")  { 1.upto(n) do ; a = "1"; end }
#   [tf+tt+tu, (tf+tt+tu)/3]
# end

# puts Benchmark.measure { "a"* 1e9}


# Benchmark.bm do |x|
#   x.report { "a"* 1e9 }
#   x.report { "a"* 1e9 }
#   x.report { "a"* 1e9 }
# end

# Benchmark.bmbm do |x|
#   x.report { "a"* 1e9 }
#   x.report { "a"* 1e9 }
#   x.report { "a"* 1e9 }
# end


# def slow
# 	yield
# end
# def fast	
# 	yield
# end
# Benchmark.ips do |x|
#   x.report("slow") { slow { "a"* 1e5 } }
#   x.report("fast") { fast { "a"* 1e5 } }
# end

# ============================= redis =============================

 # https://www.rubydoc.info/github/redis/redis-rb/master/Redis/Distributed#lpush-instance_method
 # 中文详解： https://www.cnblogs.com/funyoung/p/10730525.html


# require "redis"


# def bench(descr) 
# 	start = Time.now 
# 	yield 
# 	puts "#{descr} #{Time.now-start} seconds" 
# end

# def without_pipelining 
# 	r = Redis.new 
# 	10000.times { 
# 	    r.ping 
# 	} 
# end

# def with_pipelining 
# 	r = Redis.new 
# 	r.pipelined { 
# 		pp '>>>>>>>>>'
# 	    10000.times { 
# 	        r.ping 
# 	    } 
# 	} 
# end

# bench("without pipelining") { 
#     without_pipelining 
# } 
# puts '111111111111111'
# bench("with pipelining") { 
#     with_pipelining 
# }


# ============================= token 方法 =============================
# require 'jwt'

# params = {user_id: 'user.id', user_name: 'fdsafdsafas', avatar: 'fdsafdsafdsa'}
# key = 'test_hash_key'
# pp code = JWT.encode(params, key)
# content , func = JWT.decode(code, key)
# pp content

# ============================= hash to json deep =============================
# require 'json'
# pp root = {
#       identifier: {channel: 'OnlineChannel'},
#       command: 'subscribe'
#     }.to_s
# # pp json = root.to_json
# # pp json = json.to_json
# jhash = JSON.parse(root)
# pp jhash
# pp jhash["identifier"]["channel"]

# pp JSON.parse "[{\"identifier\":\"Daogelasi_JianGuo\",\"name\":\"道格拉斯·建国\",\"avatar\":\"https://images.12306.com/avatar/img_3617.jpg\"},{\"identifier\":\"Daogelasi_JianGuo\",\"name\":\"道格拉斯·建国\",\"avatar\":\"https://images.12306.com/avatar/img_3617.jpg\"}]"

# ============================= Hashids =============================
# require 'hashids'
# require 'jwt'

# def create_group params
#   Hashids.new('test_hash_key').encode(params.codepoints) 
# end

# def decode_group code
# 	JSON.parse(Hashids.new('test_hash_key').decode(code).map{|x| x.chr}.join)
# end

# def create_token params
#     token = JWT.encode(params, 'test_hash_key')
# 	end

# 	def decode_token token
# 		JWT.decode(token, 'test_hash_key')
# 	end

# param = {
# 	app_id: 'app_str',
# 	user_id: 'user_str',
# 	create_time: Time.now.to_i}

# pp code = create_token(param)
# a, b = decode_token(code)
# pp a['user_id']