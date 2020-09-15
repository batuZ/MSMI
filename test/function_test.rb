

# ============================= token 方法 =============================
# require 'jwt'

# params = {user_id: 'user.id', user_name: 'fdsafdsafas', avatar: 'fdsafdsafdsa'}
# key = 'test_hash_key'
# pp code = JWT.encode(params, key)
# content , func = JWT.decode(code, key)
# pp content


# ============================= hash to json deep =============================
require 'json'
pp root = {
      identifier: {channel: 'OnlineChannel'},
      command: 'subscribe'
    }.to_json
pp json = root.to_json
pp json = json.to_json
jhash = JSON.parse(json)
pp jhash
pp jhash["identifier"]["channel"]