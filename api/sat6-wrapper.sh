#!/bin/bash
# sat6-updates.sh updates our hosts automatically it is
# called from cron everyday but only runs according the 
# following schedule:
# Content View | Environments             | Date
# -------------------------------------------------------------------
# Crash        | Library --> Dev --> Prod | 1st Monday of every month
# day of the week today
dow=$( date +"%u%d" )
# if first Monday
if [[ "$dow" -ge 101 && "$dow" -le 107 ]]
then
  ## Update Crash
  # Generate new content view version
  /root/api/Sat6APIUpdateHC.py -o HO -cv Crash --create-new-version
  # Promote dev to prod
  /root/api/Sat6APIUpdateHC.py -o HO -cv Crash --promote-from-env dev --promote-to-env prod
  # Promote Library to dev
  /root/api/Sat6APIUpdateHC.py -o HO -cv Crash --promote-from-env Library --promote-to-env dev
  # remove old versions 
  /root/api/Sat6APIUpdateHC.py -o HO -cv Crash --cleanup --keep 1
# if first Tuesday
elif [[ "$dow" -ge 201 && "$dow" -le 207 ]]
then
  ## Update Infra
  # Generate new content view version
  /root/api/Sat6APIUpdateHC.py -o HO -cv Infra --create-new-version
  # Promote Library to dev
  /root/api/Sat6APIUpdateHC.py -o HO -cv Infra --promote-from-env Library --promote-to-env prod
  # remove old versions 
  /root/api/Sat6APIUpdateHC.py -o HO -cv Infra --cleanup --keep 1
# if first Wednesday
elif [[ "$dow" -ge 301 && "$dow" -le 307 ]]
then
  echo "its wednesday"
# if first Thursday
elif [[ "$dow" -ge 401 && "$dow" -le 407 ]]
then
  echo "its thursday"
# if first Friday
elif [[ "$dow" -ge 501 && "$dow" -le 507 ]]
then
  echo "its friday"
# if not any of the above (weekend) do nothing. 
else
  echo "It is a weekend - nothing to do"
fi
