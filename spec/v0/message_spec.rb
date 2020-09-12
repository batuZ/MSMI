require 'rails_helper'
version = File.basename __dir__

RSpec.describe 'Message', type: :request do
	it '发送消息接口' do
		 post "/api/#{version}/message", params: { tag_id: 'myfile', text: 'audio' }
		 pp JSON.parse(response.body)
	end
end