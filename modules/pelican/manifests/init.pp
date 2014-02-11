class pelican{
	package{"python-dev":
		ensure 		=> installed,
	}

	package{"python-pip":
		ensure 		=> installed,
		require 	=> Package["python-dev"]
	}

	package{"pelican":
		ensure 		=> installed,
		provider	=> pip,
		require 	=> Package["python-pip"]
	}
}
