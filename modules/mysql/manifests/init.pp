class mysql::server{


	define db($user, $password){
		exec{"create-${name}-db":
			unless => "/usr/bin/mysql -u${user} -p${password} ${name}",
			command => "/usr/bin/mysql -uroot -p${mysql_password} -e \"create database ${name};grant all on ${name}.* to ${user}@localhost identified by '$password';flush privileges;\"", 
			require => Exec["set-mysql-password"],
			}
	}

	package{"mysql-server":
		ensure => installed,
	}

	service{"mysql":
		enable => true,
		ensure => running,
		require => Package["mysql-server"],
	}

	file{"/etc/mysql/mycnf":
		owner => "mysql",
		group => "mysql",
		source => "puppet:///modules/mysql/my.cnf",
		notify => Service["mysql"],
		require => Package["mysql-server"],
	}

	exec{"set-mysql-password":
		unless => "/usr/bin/mysqladmin -uroot -p${mysql_password} status",
		command => "/usr/bin/mysqladmin -uroot password ${mysql_password}",
		require => Service["mysql"],
	}
}
