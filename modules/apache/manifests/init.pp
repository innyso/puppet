class apache {
    package { "apache2-mpm-prefork": ensure => installed }

    service { "apache2":
        enable  => true,
        ensure  => running,
        require => Package["apache2-mpm-prefork"],
    }

    file { "/etc/apache2/logs":
        ensure  => directory,
        require => Package["apache2-mpm-prefork"],
    }

    file { "/etc/apache2/conf.d/name-based-vhosts.conf":
        content => "NameVirtualHost *:80",
        require => Package["apache2-mpm-prefork"],
        notify  => Service["apache2"],
    }

    define snippet() { 
        file { "/etc/apache2/conf.d/${name}":
            source => "puppet:///modules/apache/${name}",
            notify => Service["apache2"],
        }
    }

    define site( $sitedomain = "", $documentroot = "",$port="80" ) {
        include apache
	
 
        if $sitedomain == ""{
            $vhost_domain = $name
        } else {
            $vhost_domain = $sitedomain
        } 
    
        if $documentroot == ""{
            $vhost_root = "/var/www/${name}"
        } else {
            $vhost_root = $documentroot
        } 
        
        file { "/etc/apache2/sites-available/${vhost_domain}.conf":
            content => template("apache/vhost.erb"),
            require => File["/etc/apache2/conf.d/name-based-vhosts.conf"],
            notify  => Exec["enable-${vhost_domain}-vhost"],
        }

        exec { "enable-${vhost_domain}-vhost":
            command     => "/usr/sbin/a2ensite ${vhost_domain}.conf",
            require     => [ File["/etc/apache2/sites-available/${vhost_domain}.conf"], Package["apache2-mpm-prefork"] ],
            refreshonly => true,
            notify      => Service["apache2"],
        }
    }
}
