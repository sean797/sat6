# Couldn't be bothered with Parms...
class puppet {

        package { "puppet":
                ensure => "latest"
                }

	service { "puppet":
		enable => false,
		ensure => "stopped",
		}

	file { '/etc/puppet/puppet.conf':
        	ensure => file,
		source  => "puppet:///modules/puppet/puppet.conf",
        	mode    => 644,
        	owner   => "root",
        	group   => "root",
       		require => Package["puppet"],
	}

        # Creates cronjob to run randomly base on the hostname every 30 minutes. 
	cron { "Puppet":
		command => "/usr/bin/puppet agent --no-daemonize --onetime > /dev/null 2>&1",
		user => "root",
		minute => [ fqdn_rand(30,$hostname), fqdn_rand(30,$hostname)+30],
		ensure => present,
	}
}
