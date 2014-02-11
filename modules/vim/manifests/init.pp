class vim{
	package{"vim":
		ensure => installed,
	}

	file{"/usr/share/vim/vimrc":
		content => template("vim/vimrc.erb"),
		require => Package["vim"],
	}
}
