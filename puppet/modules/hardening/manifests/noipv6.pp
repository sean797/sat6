class hardening::noipv6 (

  $disable_ipv6    = $hardening::params::disable_ipv6

) inherits hardening::params {

  if $disable_ipv6 {
    case $::operatingsystemrelease {
       /^6/: {
         augeas { 'modprobe_noipv6':
           context => '/files/etc/modprobe.conf',
           changes => ['set options[.="ipv6"] "ipv6"',
                       'set options[.= "ipv6"]/disable 1' ]
          }
       }
       /^7/: {
         augeas {'sysctl_disable_ipv6':
           notify  => Exec["reload-sysctl-settings"],
           context => '/files/etc/sysctl.conf',
           changes => ['set net.ipv6.conf.all.disable_ipv6 1']
         }

       }
       default: {
       }

    }
  }
}
