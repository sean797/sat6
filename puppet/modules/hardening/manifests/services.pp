class hardening::services (

  $disable_services   = $hardening::params::disable_services

) inherits hardening::params {

  if $disable_services {

    $disable_service_list=['avahi-daemon', 'nfslock', 'rpcgssd', 'rpcbind', 'rpcidmapd', 'rpcsvcgssd']
    service { $disable_service_list:
      ensure   => 'stopped',
      enable   => 'false',
    }
  }
}
