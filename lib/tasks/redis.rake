namespace :redis do
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
end
