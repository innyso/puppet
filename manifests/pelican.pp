stage{
	'setup':;
}

class{
	'apt': stage => 'setup';
	'vim': stage => 'setup';
	'nginx':;
	'pelican':;
}

Stage['setup'] -> Class['nginx'] -> Class['pelican'] 

Exec["apt-update"] -> Package <| |>
