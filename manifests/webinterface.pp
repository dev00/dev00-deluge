# == Class: deluge::webinterface
#
# This class will install the webinterface as a service unter it's own user. The daemon is not required, since
# you can connect the webinterface to other servers than the local one.
#
# === Parameters
#
#
# manage_by_puppet	= if puppet should keep control over changes to the config-file. This should not be set since it'll cause major disruption
#			  since it'll delete the session information and some more stuff, which is set by the webinterface.
#			  Use it for some kind of "reset" for the web-ui. default is false.
# port			= on which port the webserver will listen. default is 8112
# https			= if htts is used or not. or is exclusive. default is false.
# pkey			= where the pkey-file for the https-encryption is stored. The path is ALWAYS (!) relative to the config-folder.
#			  default is 'ssl/daemon.pkey'
# cert			= where the cert-file for the https-encryption is stored. The path is ALWAYS (!) relative to the config-folder.
#			  default is 'ssl/daemon.cert'
# === Examples
#
#	class { 'dev00-deluge::webinterface':
#		port 	=> '14000',
#		https	=> true,
#  	}
#
# === Authors
#
# Author Name m.rose@telekom.de
#
# === Copyright
#
# Copyright 2015 Michael "dev00" Rose
#

class dev00-deluge::webinterface(
	$port			= 8112,	
	$https			= true,
	$pkey			= 'ssl/daemon.pkey',
	$cert			= 'ssl/daemon.cert',
	$manage_by_puppet	= false,
)

{
	include dev00-deluge::base

	package { 'deluge-web':
		ensure => present,
	}

	service { 'deluge-web':
		ensure	=> running,
		require	=> Package['deluge-web'];
	}

	transition { 'stop deluge-web service':
		resource   => Service['deluge-web'],
		attributes => { ensure => stopped },
		prior_to   => File['/var/lib/deluge/web.conf'],
	}

	file {
		'/var/lib/deluge/web.conf':
			ensure		=> present,
			owner		=> deluge,
			group 		=> deluge,
			replace		=> "${manage_by_puppet}",
			mode 		=> 0644,
			content		=> template('dev00-deluge/web.conf.erb'),
			notify		=> Service['deluge-web'],
			require		=> File['/var/lib/deluge'];

# Cares about the daemon-files
		'/etc/init.d/deluge-web':
			ensure		=> present,
			mode		=> 0700,
			require 	=> File['/etc/default/deluge-web'],
			notify		=> Service['deluge-web'],
			content		=> template('dev00-deluge/deluge-web.erb');

		'/etc/default/deluge-web':
			ensure		=> present,
			owner		=> root,
			group		=> root,
			mode		=> 0700,
			notify		=> Service['deluge-web'],
			content		=> template('dev00-deluge/default_deluge_daemon.erb');

	}
}
