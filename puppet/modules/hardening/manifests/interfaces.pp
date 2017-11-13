class hardening::interfaces (

  $disable_uncommon_protocols    = $hardening::params::disable_uncommon_protocols

) inherits hardening::params {

  if $disable_uncommon_protocols {
    file {'cis_interfaces_conf':
      ensure  => file,
      path    => '/etc/modprobe.d/cis-interfaces.conf',
      source => 'puppet:///modules/hardening/cis-interfaces_modprobe.conf',
      owner   => root,
      group   => root,
      mode    => '0644',
    }
  }
}
