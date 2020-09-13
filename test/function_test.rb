

# ============================= token 方法 =============================
require 'jwt'

params = {user_id: 'user.id', user_name: 'fdsafdsafas', avatar: 'fdsafdsafdsa'}
key = 'test_hash_key'
pp code = JWT.encode(params, key)
content , func = JWT.decode(code, key)
pp content
