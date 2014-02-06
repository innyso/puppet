stage{
		'setup':;
}

Stage['setup'] => Stage['main']

class{
		'setup': stage => 'setup';
		'apache':;
		'mysql::server':;
		'drupal':;
}

mysql::server::db{"johntest":
		user => "john",
		password => "johntest",
}
