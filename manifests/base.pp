# == Class: deluge::settings
#
# Full description of class deluge here.
#
# === Parameters
#
# Document parameters here.
#
# [*sample_parameter*]
#   Explanation of what this parameter affects and what it defaults to.
#   e.g. "Specify one or more upstream ntp servers as an array."
#
# === Variables
#
# Here you should define a list of variables that this module would require.
#
# [*sample_variable*]
#   Explanation of how this variable affects the funtion of this class and if
#   it has a default. e.g. "The parameter enc_ntp_servers must be set by the
#   External Node Classifier as a comma separated list of hostnames." (Note,
#   global variables should be avoided in favor of class parameters as
#   of Puppet 2.6.)
#
# === Examples
#
#  class { 'deluge':
#    servers => [ 'pool.ntp.org', 'ntp.local.company.com' ],
#  }
#
# === Authors
#
# Author Name <author@domain.com>
#
# === Copyright
#
# Copyright 2015 Your name here, unless otherwise noted.
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
		ensure => present,
		system => true,
	}

	file {
		"/var/lib/deluge/":
			ensure	=>	directory,
			owner	=>	'deluge',
			group	=>	'deluge',
			mode	=>	0700,
			require	=>	User['deluge'];

		"/var/log/deluge":
			ensure	=>	directory,
			owner	=>	'deluge',
			group	=>	'deluge',
			mode	=>	0644;
	}




}