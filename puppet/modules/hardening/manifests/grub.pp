class hardening::grub (

  $secure_boot            = $hardening::params::secure_boot,
  $md5_grub_password      = $hardening::params::md5_grub_password,
  $grub2_superusers       = $hardening::params::grub2_superusers,
  $pbkdf2_grub2_passwords = $hardening::params::pbkdf2_grub2_passwords

) inherits hardening::params {

exec { 'refresh-grub2-config':
  command => 'grub2-mkconfig -o /boot/grub2/grub.cfg',
  path    => ['/sbin','/usr/sbin'],
  refreshonly => true,
}

  if $secure_boot {

    case $::operatingsystemrelease {
       /^6/: {
         file {'/etc/grub.conf':
           owner => root,
           group => root,
           mode  => '0600',
         }

         file {'/boot/grub/grub.conf':
           owner => root,
           group => root,
           mode  => '0600',
         }
        Grub password hasn't been tested!!!!!         
        augeas { 'grub-create-password':
          context => '/files/boot/grub/grub.conf',
          changes => [
            'ins password after default',
            "set password/md5 ''",
            "set password ${cis_md5_grub_password}",
          ],
          onlyif  => 'match password size == 0',
        }

        augeas { 'grub-set-password':
          context => '/files/boot/grub/grub.conf',
          changes => "set password ${cis_md5_grub_password}",
          require => Augeas['grub-create-password'],
        }
       }
       /^7/: {
         file {'/boot/grub2/grub.cfg':
           owner => root,
           group => root,
           mode  => '0600',
         }
         file { '/etc/grub.d/99_grub2-password':
           ensure  => file,
           owner   => root,
           group   => root,
           mode    => '0755',
           notify  => Exec["refresh-grub2-config"],
           content => template("hardening/99_grub2-password.erb"),
         }
       }
       default: {
       }
    }
  }
       
}
