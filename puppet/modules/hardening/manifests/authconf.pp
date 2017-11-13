# = Class: hardening::authconf
#
# == Authors:
#
# Author Name <ghares@redhat.com>
#
# == Copyright:
#
# Copyright 2015 Red Hat Inc, unless otherwise noted.
#
#
class hardening::authconf (

  $secure_local_accounts  = $hardening::params::secure_local_accounts

) inherits hardening::params {


  if $secure_local_accounts {

    exec {'run_set_admin_accounts_nologin_exec':
      onlyif => '/bin/bash /root/set_admin_accounts_nologin_onlyif.bash',
      command => '/bin/bash /root/set_admin_accounts_nologin_exec.bash',
      path    => ['/bin','/sbin','/usr/bin/','/usr/sbin','/root'],
      require => File['set_admin_accounts_nologin_exec_file',
                      'set_admin_accounts_nologin_onlyif_file'],
    }

   file { 'set_admin_accounts_nologin_exec_file':
      ensure  => file,
      path    => '/root/set_admin_accounts_nologin_exec.bash',
      source  => 'puppet:///modules/hardening/set_admin_accounts_nologin_exec.bash',
      owner   => 'root',
      group   => 'root',
      mode    => '0755',
    }

   file { 'set_admin_accounts_nologin_onlyif_file':
      ensure  => file,
      path    => '/root/set_admin_accounts_nologin_onlyif.bash',
      source  => 'puppet:///modules/hardening/set_admin_accounts_nologin_onlyif.bash',
      owner   => 'root',
      group   => 'root',
      mode    => '0755',
    }

    exec {'run_set_root_gid_zero_exec':
      onlyif  => '/bin/grep "^root:" /etc/passwd | /bin/cut -f4 -d: | /bin/grep -v 0',
      command => '/usr/sbin/usermod -g 0 root',
      path    => ['/bin','/sbin','/usr/bin/','/usr/sbin'],
    }

    file { 'etc_passwd_file':
      ensure  => present,
      path    => '/etc/passwd',
      owner   => root,
      group   => root,
      mode    => 0644,
    }

    file { 'etc_shadow_file':
      ensure  => present,
      path    => '/etc/shadow',
      owner   => root,
      group   => root,
      mode    => 0000,
    }

    file { 'etc_gshadow_file':
      ensure  => present,
      path    => '/etc/gshadow',
      owner   => root,
      group   => root,
      mode    => 0000,
    }

    file { 'etc_group_file':
      ensure  => present,
      path    => '/etc/group',
      owner   => root,
      group   => root,
      mode    => 0644,
    }
  }

}
