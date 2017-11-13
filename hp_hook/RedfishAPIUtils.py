import requests
import json
import syslog

class RedfishAPIUtils:
   # Init
   def __init__(self, hostname, username, password):
      self.post_headers = {'content-type': 'application/json'}
      self.put_headers = {'content-type': 'application/json'}
      self.patch_headers = {'content-type': 'application/json'}
      self.https = False
      self.protocol = 'https'
      self.hostname = hostname
      self.username = username
      self.password = password

   # Wrappers:
   # getRequest Wrapper
   def patchRequest(self,url,data=False,**kwargs):
      self.url = url
      self.data = data
      # Generate the URL
      self.fullurl = "%s://%s/%s" % (self.protocol, self.hostname, self.url)
      r = requests.patch(self.fullurl, auth=(self.username, self.password), verify=self.https, data=json.dumps(self.data), headers=self.put_headers)
      if not r.status_code == 200:
         syslog.syslog("Error, patch: API call failed! (url: '"+self.fullurl+"', params: '"+str(data)+"', response: '"+str(r.content)+"')")
         return 1
      return r.content
   def postRequest(self,url,data=False,**kwargs):
      self.url = url
      self.data = data
      # Generate the URL
      self.fullurl = "%s://%s/%s" % (self.protocol, self.hostname, self.url)
      r = requests.post(self.fullurl, auth=(self.username, self.password), verify=self.https, data=json.dumps(self.data), headers=self.put_headers)
      if not r.status_code == 200:
         syslog.syslog("Error, patch: API call failed! (url: '"+self.fullurl+"', params: '"+str(data)+"', response: '"+str(r.content)+"')")
         return 1
      return r.content

   def mount_virtual_media_iso(self, iso_path, BootOnNextServerReset):
      url = 'redfish/v1/Managers/1/VirtualMedia/2/'
      data = {"Image": iso_path, 
              "Oem": {"Hp": {"BootOnNextServerReset": BootOnNextServerReset}}}
      syslog.syslog('Sending API request to {} to mount {}, BootOnNextServerReset set to {}'.format(self.hostname, iso_path, BootOnNextServerReset))
      retstat = self.patchRequest(url, data)
      return retstat
   def reset_server(self):
      url = 'redfish/v1/Systems/1/'
      data = {"Action": "Reset", "ResetType": "ForceRestart"}
      syslog.syslog('Sending API request to reboot {}'.format(self.hostname))
      retstat = self.postRequest(url, data)
      return retstat
