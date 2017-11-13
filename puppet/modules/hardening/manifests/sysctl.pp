class hardening::sysctl (

  $secure_processes    = $hardening::params::secure_processes,
  $disable_router      = $hardening::params::disable_router

) inherits hardening::params {

  exec { 'reload-sysctl-settings':
    command => '/usr/sbin/sysctl -p',
    path    => ['/sbin','/usr/sbin'],
    refreshonly => true,
  }


  if $secure_processes {

    augeas {'sysctl_core_dumps':
      notify  => Exec["reload-sysctl-settings"],
      context => '/files/etc/sysctl.conf',
      changes => [ 'set fs.suid_dumpable 0']
    }

    augeas {'sysctl_randomized_virt_mem':
      notify  => Exec["reload-sysctl-settings"],
      context => '/files/etc/sysctl.conf',
      changes => ['set kernel.randomize_va_space 2']
    }

    if $::operatingsystemmajrelease == '6' { 

      augeas { 'sysctl_exec_shield':
        notify  => Exec["reload-sysctl-settings"],
        context => '/files/etc/sysctl.conf',
        changes => ['set kernel.exec-shield 1']
      }
    }
  }

  if $disable_router {

    augeas {'sysctl_disable_ip_forwarding':
      notify  => Exec["reload-sysctl-settings"],
      context => '/files/etc/sysctl.conf',
      changes => ['set net.ipv4.ip_forward 0',
                  'set net.ipv4.route.flush 1'],
    }

    augeas {'sysctl_disable_network_send_redirects':
      notify  => Exec["reload-sysctl-settings"],
      context => '/files/etc/sysctl.conf',
      changes => ['set net.ipv4.conf.all.send_redirects 0',
                  'set net.ipv4.conf.default.send_redirects 0',
                  'set net.ipv4.route.flush 1'],
    }

    augeas {'sysctl_disable_source_routed_packet_acceptance':
      notify  => Exec["reload-sysctl-settings"],
      context => '/files/etc/sysctl.conf',
      changes => ['set net.ipv4.conf.all.accept_source_route 0',
                  'set net.ipv4.conf.default.accept_source_route 0',
                  'set net.ipv4.route.flush 1'],
    }

    augeas {'sysctl_disable_network_accept_redirects':
      notify  => Exec["reload-sysctl-settings"],
      context => '/files/etc/sysctl.conf',
      changes => ['set net.ipv4.conf.all.accept_redirects 0',
                  'set net.ipv4.conf.default.accept_redirects 0',
                  'set net.ipv4.route.flush 1'],
    }

    augeas {'sysctl_secure_network_redirects':
      notify  => Exec["reload-sysctl-settings"],
      context => '/files/etc/sysctl.conf',
      changes => ['set net.ipv4.conf.all.secure_redirects 0',
                  'set net.ipv4.conf.default.secure_redirects 0',
                  'set net.ipv4.route.flush 1'],
    }

    augeas {'sysctl_log_suspicious_packets':
      notify  => Exec["reload-sysctl-settings"],
      context => '/files/etc/sysctl.conf',
      changes => ['set net.ipv4.conf.all.log_martians 1',
                  'set net.ipv4.conf.default.log_martians 1',
                  'set net.ipv4.route.flush 1'],
    }

    augeas {'sysctl_ignore_broadcast_requests':
      notify  => Exec["reload-sysctl-settings"],
      context => '/files/etc/sysctl.conf',
      changes => ['set net.ipv4.icmp_echo_ignore_broadcasts 1',
                  'set net.ipv4.route.flush 1'],
    }

    augeas {'sysctl_ignore_bad_error_messages':
      notify  => Exec["reload-sysctl-settings"],
      context => '/files/etc/sysctl.conf',
      changes => ['set net.ipv4.icmp_ignore_bogus_error_responses 1',
                  'set net.ipv4.route.flush 1'],
    }

    augeas {'sysctl_enable_tcp_syn_cookies':
      notify  => Exec["reload-sysctl-settings"],
      context => '/files/etc/sysctl.conf',
      changes => ['set net.ipv4.tcp_syncookies 1',
                  'set net.ipv4.route.flush 1'],
    }
  }
}
