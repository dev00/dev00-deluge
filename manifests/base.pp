# == Class: deluge::base
#
# Provides the basic settings which both (Web-UI and the daemon) require. In this case
# the user, the group, the config-folder /var/lib/deluge and the log-folder /var/log/deluge 
#

class dev00-deluge::base()
{

	user { 'deluge':
		ensure		=> present,
		system		=> true,
		shell		=> '/bin/false',
		password	=> '*',
		groups		=> deluge;
	}

	group { 'deluge':
		ensure		=> present,
		system		=> true,
	}

	file {
		"/var/lib/deluge/":
			ensure	=> directory,
			owner	=> 'deluge',
			group	=> 'deluge',
			mode	=> 0700,
			require	=> User['deluge'];

		"/var/log/deluge":
			ensure	=> directory,
			owner	=> 'deluge',
			group	=> 'deluge',
			mode	=> 0644;
	}
}
