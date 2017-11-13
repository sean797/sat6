class hardening::params (

  $secure_partitions            = true,
  $secure_boot	                = true,
  $md5_grub_password            = '$1$LtwV7$STi40hx/AZvfMbI9sfjZY/',
  $secure_processes             = true,
  $remove_pkgs                  = true,
  $install_pkgs                 = true,
  $disable_ipv6			= true,
  $secure_services              = true,
  $disable_services             = true,
  $disable_router               = true, # Needs to be disabled for hypervisors
  $disable_uncommon_protocols   = true,
  $secure_local_accounts        = true,
  $secure_cron                  = true,
  $grub2_superusers             = undef, # Should contain any array of users. The User and Password for that user must the same element in both array's
  $pbkdf2_grub2_passwords       = undef, # Should contain an array of pbkdf2 hashed passwords. The User and Password for that user must the same element in both array's.
  $cron_allow_users             = ["root",]

) {

  validate_bool($secure_partitions)
  validate_bool($secure_boot)
  validate_string($md5_grub_password)
  validate_bool($secure_processes)
  validate_bool($remove_pkgs)
  validate_bool($install_pkgs)
  validate_bool($secure_services)
  validate_bool($disable_services)
  validate_bool($disable_router)
  validate_bool($disable_ipv6)
  validate_bool($disable_uncommon_protocols)
  validate_bool($secure_cron)
  validate_array($cron_allow_users)
  validate_array($grub2_superusers)
  validate_array($pbkdf2_grub2_passwords)
  validate_bool($secure_local_accounts)

}
