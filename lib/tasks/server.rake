namespace :server do
	desc '后台启动server_production'
	task :start_p => :environment do
		p_file = "tmp/pids/server.pid"
		e_file = "tmp/pids/server.env"
		if File.exist?( p_file )
			puts "程序正在后台运行，状态: #{IO.readlines(e_file).first} - #{IO.readlines(p_file).first}"	
		else

			puts "【警告】即将后台启动【生产】环境，此环境将影响生产数据库，确定？[y] or [n]"
			confirm1 = STDIN.gets
			return unless confirm1.eql?"y\n"

			puts '清理静态资源...'
			raise '清理静态资源失败' unless system 'RAILS_ENV=production rails assets:clobber'
			puts '静态资源清理完成'
				
			puts '编译静态资源...'
	    raise '编译静态资源失败' unless system 'RAILS_ENV=production rails assets:precompile'
	    puts '静态资源编译完成'
	    
	    puts '检查 redis-server...'
	  	raise '启动redis-server失败' unless system 'nohup redis-server &' unless system('redis-cli ping')

			puts '后台启动production服务...'
			raise '启动production服务失败' unless system 'nohup rails s -b 0.0.0.0 -e production &'
	    puts "production服务已经后台启动成功。"	

	    File.open(e_file, "w") do |aFile|
			  aFile.puts 'production'
			end
		end
	end

	desc '后台启动server_development'
	task :start_d => :environment do
		p_file = "tmp/pids/server.pid"
		e_file = "tmp/pids/server.env"
		if File.exist?( p_file )
			puts "程序正在后台运行，状态: #{IO.readlines(e_file).first} - #{IO.readlines(p_file).first}"	
		else

			puts "【警告】即将后台启动【开发】环境，此环境将影响开发数据库，确定？[y] or [n]"
			confirm1 = STDIN.gets
			return unless confirm1.eql?"y\n"

			puts '检查 redis-server...'
	  	raise '启动redis-server失败' unless system 'nohup redis-server &' unless system('redis-cli ping')

			puts 'development 服务开始后台启动...'
			raise '启动development服务失败' unless system 'nohup rails s -b 0.0.0.0 &'
	    puts "development 服务已经后台启动成功。"	

	    File.open(e_file, "w") do |aFile|
			  aFile.puts 'development'
			end
	  end
	end

	desc '后台启动server_test'
	task :start_t => :environment do
		p_file = "tmp/pids/server.pid"
		e_file = "tmp/pids/server.env"
		if File.exist?( p_file )
			puts "程序正在后台运行，状态: #{IO.readlines(e_file).first} - #{IO.readlines(p_file).first}"	
		else
			puts "【警告】即将后台启动【测试】环境，确定？[y] or [n]"
			confirm1 = STDIN.gets
			return unless confirm1.eql?"y\n"

			puts '初始化test数据库...'
			raise '初始化test数据库失败' unless system 'RAILS_ENV=test bin/rails db:reset'

			puts '检查 redis-server...'
	  	raise '启动redis-server失败' unless system 'nohup redis-server &' unless system('redis-cli ping')

			puts 'test 服务开始后台启动...'
			raise 'test 服务启动失败' unless system 'nohup rails s -e test &'
	    puts "test 服务已经后台启动成功。"	

	    File.open(e_file, "w") do |aFile|
			  aFile.puts 'test'
			end
		end
	end

	desc '检查运行状态'
	task :check => :environment do
		p_file = "tmp/pids/server.pid"
		e_file = "tmp/pids/server.env"
		if File.exist?( p_file )
			puts "程序正在后台运行，状态: #{IO.readlines(e_file).first} - #{IO.readlines(p_file).first}"	
		else
	    puts '程序未启动'	
	  end
	end

	desc '关闭server进程'
	task :stop => :environment do
		p_file = "tmp/pids/server.pid"
		if File.exist?(p_file)
			pid = IO.readlines(p_file).first.to_i
			raise '停止服务启动失败' unless system "kill #{pid}"
			puts "rails(PID:#{pid}) 服务已经停止... 	"
		else
			puts "程序未启动"
		end
	end

end



