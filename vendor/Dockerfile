FROM centos:7.6.1810

# --- v1 580MB
RUN rpm -ivh https://dev.mysql.com/get/mysql80-community-release-el7-3.noarch.rpm --force --nodeps \
	&& yum -y install update \
			wget \
			which \
			perl \
			gcc \
			gcc-c++ \
			cmake make tcl \
			openssl-devel \
			zlib \
			zlib-devel \
			readline-devel \
			gdbm-devel \
			pcre-devel \
			ncurses-devel \
			libyaml-devel \
			libxml2-devel \
			ruby-devel \
			rpm-build \
			mariadb.x86_64 \
			mariadb-libs.x86_64 \
	# && wget https://cache.ruby-lang.org/pub/ruby/ruby-2.5.5.tar.gz \
	# && tar xvf ruby-2.5.5.tar.gz 	&& rm -f ruby-2.5.5.tar.gz \
	# && cd ruby-2.5.5 							&& ./configure \
	# && make 											&& make install \
	# && cd .. 											&& rm -rf ruby-2.5.5 \
	# && gem sources --remove https://rubygems.org/ -a https://gems.ruby-china.com \
	# && gem update --system 3.0.3 && gem update -f \
	# && gem install mysql2 therubyracer bundler -f \
	# && gem install rails -v '5.2.4' -f


# docker build -t 304701204/ruby_on_rails:2.5.5-5.2.4-centos .
