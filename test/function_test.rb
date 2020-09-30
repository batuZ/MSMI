



 # --------  redis ---------------------------------------------------------
 # https://www.rubydoc.info/github/redis/redis-rb/master/Redis/Distributed#lpush-instance_method
 # 中文详解： https://www.cnblogs.com/funyoung/p/10730525.html
# ============================= token 方法 =============================
# require 'jwt'

# params = {user_id: 'user.id', user_name: 'fdsafdsafas', avatar: 'fdsafdsafdsa'}
# key = 'test_hash_key'
# pp code = JWT.encode(params, key)
# content , func = JWT.decode(code, key)
# pp content

a = [1,2,3]
b = [1,2,5,7]
pp b - a
# ============================= hash to json deep =============================
require 'json'
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