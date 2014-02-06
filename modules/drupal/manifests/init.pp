class drupal {
    $drupalversion = "7.2"

    exec { "download-drush":
        cwd     => "/root",
        command => "/usr/bin/wget http://ftp.drupal.org/files/projects/drush-7.x-4.4.tar.gz",
        creates => "/root/drush-7.x-4.4.tar.gz",
        require => Package["php5-mysql"],
    }

    exec { "install-drush":
        cwd     => "/usr/local",
        command => "/bin/tar xvzf /root/drush-7.x-4.4.tar.gz",
        creates => "/usr/local/drush",
        require => Exec["download-drush"],
    }

    file { "/usr/local/bin/drush":
        ensure  => link,
        target  => "/usr/local/drush/drush",
        require => Exec["download-drush"],
    }

    exec { "install-drupal":
        cwd     => "/var/www",
        command => "/usr/local/drush/drush dl drupal-${drupalversion}",
        creates => "/var/www/drupal-${drupalversion}",
        require => Exec["install-drush"],
    }

    file { "/var/www/drupal":
        ensure  => link,
        target  => "/var/www/drupal-${drupalversion}",
        require => Exec["install-drupal"],
    }

    package { [ "libapache2-mod-php5", "php5-gd","php-db",
                "php5-mysql" ]: ensure => installed }

    exec {"enable-mod-php5":
        command => "/usr/sbin/a2enmod php5",
        creates => "/etc/apache2/mods-enabled/php5.conf",
        require => Package["libapache2-mod-php5"],
    }

		exec {"enable rewrite":
			command => "/usr/sbin/a2enmod rewrite",
			require => Exec["install-drupal"]
		}

    define site( $password, $sitedomain = "",$port="80" ) {
        include drupal
    
        if $sitedomain == ""{
            $drupal_domain = $name
        } else {
            $drupal_domain = $sitedomain
        } 
    
        $dbname = regsubst( $drupal_domain, "\.", "" )
        mysql::server::db { $dbname:
            user     => $dbname,
            password => $password,
        }

        exec { "site-install-${name}":
            cwd       => "/var/www/drupal",
            command   => "/usr/local/bin/drush site-install standard -y --db-url=mysql://${dbname}:${password}@localhost/${dbname} --site-name=${dbname}",
            creates   => "/var/www/drupal/sites/${drupal_domain}",
            require   => [ File["/var/www/drupal"], Exec["install-drupal"], Mysql::Server::Db[$dbname] ],
            logoutput => true,
        }

        apache::site { $drupal_domain:
            documentroot => "/var/www/drupal",
						port=> $port,
				}
    }
}
