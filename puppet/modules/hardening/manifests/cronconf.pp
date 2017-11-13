class hardening::cronconf (

  $secure_cron      = $hardening::params::secure_cron,
  $cron_allow_users = $hardening::params::cron_allow_users

) inherits hardening::params {

  package { 'cronie':
    ensure => latest,
  }

  package { 'crontabs':
    ensure => latest,
  }


  if $secure_cron {

    file { 'anacontab_file':
      ensure  => file,
      path    => '/etc/anacrontab',
      owner   => root,
      group   => root,
      mode    => '0600',
    }

    file { 'crontab_file':
      ensure  => file,
      path    => '/etc/crontab',
      owner   => root,
      group   => root,
      mode    => '0644',
      notify  => Service['crond'],
    }

    service { 'crond':
      enable => true,
      ensure => running,
      require => File['crontab_file']
    }

    file { 'cron_hourly_directory':
      ensure  => directory,
      path    => '/etc/cron.hourly',
      owner   => root,
      group   => root,
      mode    => '0755',
    }

    file { 'cron_daily_directory':
      ensure  => directory,
      path    => '/etc/cron.daily',
      owner   => root,
      group   => root,
      mode    => '0755',
    }

    file { 'cron_weekly_directory':
      ensure  => directory,
      path    => '/etc/cron.weekly',
      owner   => root,
      group   => root,
      mode    => '0755',
    }

    file { 'cron_monthly_directory':
      ensure  => directory,
      path    => '/etc/cron.monthly',
      owner   => root,
      group   => root,
      mode    => '0755',
    }

    file { 'cron_d_directory':
      ensure  => directory,
      path    => '/etc/cron.d',
      owner   => root,
      group   => root,
      mode    => '0755',
    }

    file { 'at_allow_file':
      ensure  => file,
      path    => '/etc/at.allow',
      content => template('hardening/at.allow.erb'),
      owner   => root,
      group   => root,
      mode    => '0644',
    }

    file { 'cron_allow_file':
      ensure  => file,
      path    => '/etc/cron.allow',
      content => template('hardening/cron.allow.erb'),
      owner   => root,
      group   => root,
      mode    => '0644',
    }

  }

}
