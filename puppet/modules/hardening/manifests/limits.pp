class hardening::limits (

  $secure_processes    = $hardening::params::secure_processes

) inherits hardening::params {

  if $secure_processes {

    file { 'cis_limits_file':
      ensure  => present,
      path    => '/etc/security/limits.d/cis_limits.conf',
      source => 'puppet:///modules/hardening/cis_limits.conf',
      owner   => root,
      group   => root,
      mode    => '0644',
    }

  }
}
