# == Class: dev00-deluge::server
#
# This class will install deluged headless as a service unter it's own user. It will NOT install
# the GTK-UI, the Web-UI or the deluge-console!
#
# === Parameters
#
#
# manage_by_puppet			=	if puppet should keep control over changes to the config-file. this must not be if users should manage deluge also via
#								external interfaces (GTK-UI, deluge-conse or Web-UIs). Note that if you set it to true, you have to restart the daemon
#								by yourself after changing the config! Note also that changes for Plugins use their own config file, so they will still
#								work.
#								default is true.
# allow_remote				=	if remote connections (like GTK-UI or external webinterfaces) can connect. default is 'true'
# deluged_user				=	array of users and their password for deluged. Must be an array and look like 'user:password:level'
# 								for information about level please visit http://dev.deluge-torrent.org/wiki/UserGuide/Authentication
#								default is 'test:user:10' <-- CHANGE THIS PLEASE!
# thinclient_port			=	on which port the daemon should listen for the ThinClients. default is 58846
# thinclient_interface		=	the IP on which the daemon should listen for the ThinClients. default is empty for all interfaces.
# random_port				=	if it should randomize the ports used for p2p. default is true
# listen_port_range			=	the port range on which the daemon will listen for incoming p2p-connections. Must be an array and look like
#								'startport','endport'. default goes from 6881 to 6891
# listen_interface			=	the IP on which the daemon will listen for incoming p2p-connections. default ist empty
# random_outgoing_ports		=	if it should randomize the outgoing ports used for p2p. default is true
# outgoing_port_range		=	the ports the daemon will use for outgoing p2p-connections must be an array and look like
#								'startport','endport'. default goes from 0 to 0
# download_location			=	where the downloaded torrent-files should be located. please ensure the user deluge has write-permissions for that folder!
#							= 	default goes to '/var/cache/deluge/downloading'
# move_completed			=	if completed downloads should be moved. default is 'false'
# move_completed_path		=	where finished downloads should go
# autoadd_enable			=	if deluged should watch a specific folder and auto-add the torrents from there. default is false
# autoadd_location			=	the watched folder which deluged should monitor. default is '/var/cache/deluge/watched'
# copy_torrent_file			=	if deluged should create a copy of every torrent it gets. default is false
# torrentcopy_location		=	where the said copy should go. default is /var/cache/deluge/torrentcopy
# del_copy_after_delete		=	if the copy should be deleted after finishing the download. default is false
# add_paused				=	if the added torrents should be paused per default. default is false
# enabled_plugins			=	array of  which Plugins will be enabled per default. default is "Label"
# max_upload_speed			=	max upload speed in kb/s. default is -1.0 for unlimited
# max_download_speed		= 	max download speed in kb/s. default is -1.0 for unlimited
# max_active_downloading	=	max amount of downloads at one time. default is 3
# max_active_seeding   		=	max amount of uploads at one time. default is 5
# max_active_limit			=	total amount of up- and downloads at one time. default is 8
# dht						=	if dht should be used. default ist true
# cache_size				=	the cache size in kb. default is 512
#
# === Examples
#
#  class { 'dev00-deluge::server':
#		deluged_user	=> 	[
#								'hans:peter:10'
#							],
#		thinclient_port	=>	15000,
#		add_paused		=>	true,	
#  }
#
# === Authors
#
# Author Name m.rose@telekom.de
#
# === Copyright
#
# Copyright 2015 Michael "dev00" Rose
#


class dev00-deluge::server (
	$manage_by_puppet		=	true,
	$allow_remote			=	true,
	$deluged_user			= 	[
									'test:user:10',
								],
	$thinclient_port		=	58846,
	$thinclient_interface	=	'',
	$random_port			=	true,
	$listen_port_range		=	[
									'6881',
									'6891'
								],
	$listen_interface		=	'',
	$random_outgoing_ports	=	true,
	$outgoing_port_range	=	[
									'0',
									'0'
								],
	$download_location		=	'/var/cache/deluge/downloading',
	$move_completed 		=	false,
	$move_completed_path	=	'/var/cache/deluge/completed',
	$autoadd_enable			=	false,
	$autoadd_location		=	'/var/cache/deluge/watched',
	$copy_torrent_file		=	false,
	$torrentcopy_location	=	'/var/cache/deluge/torrentcopy',
	$del_copy_after_delete	=	false,
	$add_paused				=	false,
	$enabled_plugins		=	[
									"Label"
								],
	$max_upload_speed		=	-1.0,
	$max_download_speed		= 	-1.0,
	$max_active_downloading =	3,
	$max_active_seeding   	=	5,
	$max_active_limit		=	8,
	$dht					=	true,
	$cache_size				=	512,
)
{
	include dev00-deluge::base

	package {
		'deluged':
			ensure 	=> present;
	}

	service {
		'deluged':
			ensure 		=> 	running,
			require		=> 	[
								Package['deluged'],
								File['/etc/init.d/deluged'],
							];						
	}

	transition { 'stop deluged service':
		resource   => Service['deluged'],
		attributes => { ensure => stopped },
		prior_to   => File['/var/lib/deluge/core.conf'],
	}
	
	file {
		'/var/cache/deluge':
			ensure	=>	directory,
			owner	=>	'deluge',
			group	=>	'deluge',
			mode	=>	0700;

		"/var/lib/deluge/core.conf":
			ensure 	=> present,
			content	=> template('dev00-deluge/core.conf.erb'),
			replace	=> "${manage_by_puppet}",
			owner	=> 'deluge',
			group	=> 'deluge',
			mode	=> 0644,
			notify	=> Service['deluged'],
			require	=> File['/var/lib/deluge'];

		"/var/lib/deluge/auth":
			ensure 	=> present,
			content	=> template('dev00-deluge/auth.erb'),
			notify	=> Service['deluged'],
			owner	=> 'deluge',
			group	=> 'deluge',
			mode	=>	0600,	
			require	=> File['/var/lib/deluge'];

		"${download_location}":
			ensure	=>	directory,
			owner	=>	'deluge',
			group	=>	'deluge',
			mode	=>	0640,
			require	=> File["/var/cache/deluge"];

# === Creates init.d-Scripts for Debian, currently the only supported distribution

		'/etc/default/deluged':
			ensure	=>	'present',
			owner	=>	"root",
			group	=>	"root",
			mode	=>	0700,
			notify	=> Service['deluged'],
			content	=>	template('dev00-deluge/default_deluge_daemon.erb');

		'/etc/init.d/deluged':
			ensure	=>	'present',
			owner	=>	"root",
			group	=>	"root",
			mode	=>	0700,
			require	=>	File['/etc/default/deluged'],
			notify	=> Service['deluged'],
			content	=>	template('dev00-deluge/deluged.erb');
	}

# === Creates the folders for download if necessary, since deluge is not allowed to write anywhere
# === where it was not alllowed (deny-all principle)

	if str2bool("$move_completed")
	{
		file {
			"${move_completed_path}":
				ensure	=>	directory,
				owner	=>	'deluge',
				group	=>	'deluge',
				mode	=>	0644,
				require	=> File["/var/cache/deluge"];
		}
	}

	if str2bool("$autoadd_enable")
	{
		file {
			"${autoadd_location}":
				ensure	=>	directory,
				owner	=>	'deluge',
				group	=>	'deluge',
				mode	=>	0644,
				require	=> File["/var/cache/deluge"];
		}
	}

	if str2bool("$copy_torrent_file")
	{
		file {
			"${torrentcopy_location}":
				ensure	=>	directory,
				owner	=>	'deluge',
				group	=>	'deluge',
				mode	=>	0644,
				require	=> File["/var/cache/deluge"];
		}
	}
}

