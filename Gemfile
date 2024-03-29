source 'https://gems.ruby-china.com'
# source 'http://rubygems.org/'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.7.2'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.2.4', '>= 5.2.4.3'

# Use sqlite3 as the database for Active Record
gem 'sqlite3'

# Use Puma as the app server
gem 'puma', '~> 3.11'

# Use SCSS for stylesheets
# gem 'sass-rails', '~> 5.0'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'

# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'mini_racer', platforms: :ruby

# Use CoffeeScript for .coffee assets and views
# gem 'coffee-rails', '~> 4.2'

# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
# gem 'jbuilder', '~> 2.5'

# Use Redis adapter to run Action Cable in production
gem 'redis', '~> 4.0'
gem "hiredis", "~> 0.6.0"

# API
gem 'grape', '~> 1.3.0'

# 管理返回值并格式化对象为json
# gem 'grape-entity', '~> 0.7.1'

# api文档可视化  
gem 'grape-swagger'
gem 'grape-swagger-rails'
# gem 'grape-swagger-entity'

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# 生成mstoken
gem 'jwt', '~> 2.2.1'

# 可以从一个或多个数字生成类似YouTube的ID。https://github.com/peterhellberg/hashids.rb
# gem 'hashids', '~> 1.0.5'

gem 'uuidtools'

# 阿里云rubysdk, 手动管理OSS  https://help.aliyun.com/document_detail/32115.html?spm=a2c4g.11186623.6.1136.368f20bePH6jFP
gem 'aliyun-sdk'
gem 'activestorage-aliyun'

# Use ActiveStorage variant
# gem 'mini_magick', '~> 4.8'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# for apple notification
gem 'net-http2'
gem 'apnotic'

# 在centOS中rails需要Javascript runtime支持数据库操作
install_if -> { RUBY_PLATFORM =~ /linux/ } do
  gem 'therubyracer',  platforms: :ruby 
end

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.1.0', require: false

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'pry-rails' # 不错的调试工具
  # gem 'debase', '~> 0.2.4.1'  # 这个装不上
  # gem 'ruby-debug-ide', '~> 0.7.2'
  # gem 'debugger2'
  gem 'rspec-rails', '~> 4.0'
  gem 'benchmark-ips'
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

group :test do
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '>= 2.15'
  gem 'selenium-webdriver'
  # Easy installation and use of chromedriver to run system tests with Chrome
  gem 'chromedriver-helper'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
