class hardening::boot (

  $secure_boot            = $hardening::params::secure_boot,
  $secure_services        = $hardening::params::secure_services,

) inherits hardening::params {

  if $secure_boot {
     case $::operatingsystemrelease {
       /^6/: {
         augeas { 'init-single-user-auth':
           context => '/files/etc/sysconfig/init',
           changes => 'set SINGLE /sbin/sulogin',
         }

         augeas { 'init-disable-interactive-boot':
           context => '/files/etc/sysconfig/init',
           changes => 'set PROMPT no',
         }
       }
       /^7/: {
         # Do Nothing
       }
       default: {
       }
    }
  }

  if $secure_services {

    augeas { 'init-default-umask':
      context => '/files/etc/sysconfig/init',
      changes => 'set umask 027',
    }
  }

}
