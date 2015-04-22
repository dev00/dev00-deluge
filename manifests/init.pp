# == Class: deluge
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
class deluge (
	$daemon_user			=>	'deluge',
	$daemon_group			=>	'deluge',
	$home_basis				=>	'/home',
	$logpath				=>	'/var/log/deluge',
	$allow_remote			=>	'true',
	$deluged_user			=> 	[
									'localclient:i1t4xrxubtxxpd43cglnzjnn9ymyk5l0nczgdoxf:10',
								],
	$daemon_port			=>	'58846',
	$random_port			=>	'true',
	$listen_ports			=>	[
									'6881',
									'6891'
								],
	$random_outgoing_ports	=>	'true',
	$outgoing_ports 		=>	[
									'0',
									'0'
								],								
	$download_location		=>	'$home_basis/$user/downloading'
	$move_completed 		=>	'false',
	$move_completed_path	=>	'$home_basis/$user/completed',
	$autoadd_enable			=>	'false',
	$autoadd_location		=>	'$home_basis/$user/watched',
	$copy_torrent_file		=>	'false',
	$torrentcopy_location	=>	'/home/$user/torrentcopy',
	$del_copy_after_delete	=>	'false',
	$add_paused				=>	'false',
	$plugins_location		=> 	'/home/$user/.config/deluge/plugins',
	$enabled_plugins		=>	'Labels',
	$max_upload_speed		=>	'-1',
	$max_download_speed		=> 	'-1',
	$dht					=>	'false',
	$cache_size				=>	'512',

)
{
	package {
		'deluged':
			ensure 	=> present,
	}

	group { $group:
		ensure => present,
		system => true,
	}

	user { $user:
		ensure		=> present,
		home		=> '$home_basis/$user',
		shell		=> '/bin/false',
		password	=> '*',
		system		=> true,
		gid			=> $group,
		require		=> Group[$group,],
	}

	service {
		'deluged':
			ensure 		=> running,
	}

	file {
		'$home_basis/$user/.config/deluge/core.conf':
			ensure 	=> present,
			content	=> template(deluge/core.conf.erb);

		'$home_basis/$user/.config/deluge/auth'
			ensure 	=> present,
			content	=> template(deluge/core.conf.erb);

		'$logpath':
			ensure	=>	'directory',
			owner	=>	'$daemon_user',
			group	=>	'$daemon_user',
			mode	=>	'640';
	}
}
