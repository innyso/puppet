class rake{
	package{"rake":
		ensure  => present,
		provider => gem,
	}
}
