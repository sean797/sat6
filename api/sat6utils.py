import requests
import json
import ConfigParser
import os
import time

class Sat6APIUtils:
   # Init
   def __init__(self):
      self.delete_headers = {'content-type': 'application/json'}
      self.post_headers = {'content-type': 'application/json'}
      self.put_headers = {'content-type': 'application/json'}
      self.https = False
      self.protocol = 'https'
      homedir = os.environ.get("HOME")
      if not os.path.isfile(homedir + '/.sat6apirc'):
         print "Error, ~/.sat6apirc does not exist!"
         exit(1)
      
      sat6config = ConfigParser.ConfigParser()
      sat6config.readfp(open(homedir+'/.sat6apirc','r'))
      self.hostname = sat6config.get('sat6apiconn', 'hostname')
      self.username = sat6config.get('sat6apiconn', 'username')
      self.password = sat6config.get('sat6apiconn', 'password')
   # Wrappers:
   # getRequest Wrapper
   def getRequest(self,url,**kwargs):
      self.url = url
      # Generate the URL
      self.fullurl = "%s://%s/%s" % (self.protocol, self.hostname, self.url)
      r = requests.get(self.fullurl, auth=(self.username, self.password), verify=self.https, params=kwargs)
      if not str(r).find("[200]"):
         print "Error, get: API call failed! (url: '"+self.fullurl+"', params: '"+str(kwargs)+"', response: '"+str(r)+"')"
         return 1
      return r.json()
   # putRequest Wrapper
   def putRequest(self,url,data):
      self.url = url
      self.data = data
      # Generate the URL
      self.fullurl = "%s://%s/%s" % (self.protocol, self.hostname, self.url)
      r = requests.put(self.fullurl, auth=(self.username, self.password), verify=self.https, data=json.dumps(self.data), headers=self.put_headers)
      # Success response is: Response [200]
      if str(r).find("[200]"):
         return 0
      else:
         print "Error, putRequest: API call failed! (url: '"+self.fullurl+"', data: '"+str(self.data)+"', response: '"+str(r)+"')"
         return 1
      print 'finished'
      return 1
   # postRequest Wrapper
   def postRequest(self,url,data):
      self.url = url
      self.data = data
      # Generate the URL
      self.fullurl = "%s://%s/%s" % (self.protocol, self.hostname, self.url)
      r = requests.post(self.fullurl, auth=(self.username, self.password), verify=self.https, data=json.dumps(self.data), headers=self.post_headers)
      # Success response is: Response [200]
      #if "[200]" in r: 
      if str(r).find("[200]"):
         return r.json()
      else:
         print "Error, postRequest: API call failed! (url: '"+self.fullurl+"', data: '"+str(self.data)+"', response: '"+str(r)+"')"
         return 1
      return 1
   def deleteRequest(self,url,data):
      self.url = url
      self.data = data
      # Generate the URL
      self.fullurl = "%s://%s/%s" % (self.protocol, self.hostname, self.url)
      r = requests.delete(self.fullurl, auth=(self.username, self.password), verify=self.https, data=json.dumps(self.data), headers=self.delete_headers)
      # Success response is: Response [200]
      #if "[200]" in r: 
      if str(r).find("[200]"):
         return r.json()
      else:
         print "Error, deleteRequest: API call failed! (url: '"+self.fullurl+"', data: '"+str(self.data)+"', response: '"+str(r)+"')"
         return 1
      return 1
   def checktask(self, uuid):
      while True:
         time.sleep(1)
         task_state = self.getRequest("foreman_tasks/api/tasks/{uuid}".format(uuid = uuid)) 
         if (task_state['result'] == 'success') or (task_state['result'] == 'error'):
             break
   # GET:
   def getOrganizationByName(self,organization_label):
      return self.getRequest('katello/api/v2/organizations', search=organization_label, full_results='yes')['results'][0]
   def getOrganizationIDByName(self,organization_label):
      return self.getOrganizationByName(organization_label)[u'id']
   def getContentViews(self,organization_id):
      return self.getRequest('katello/api/v2/content_views', organization_id=organization_id)
   def getLVEnvIDbyName(self,organization_id,environment):
      env_results = self.getRequest('katello/api/v2/environments', organization_id=organization_id, search=environment, full_results='yes')
      return env_results['results'][0]['id']
   def getCVIDbyName(self,organization_id,content_view):
      cv_results = self.getRequest('katello/api/v2/content_views', organization_id=organization_id, search=content_view, full_results='yes')
      return cv_results['results'][0]['id']
   def getHostCollectionID(self,org_id,host_collection):
      url = 'katello/api/v2/organizations/%s/host_collections' % (org_id)
      host_collection_info = self.getRequest(url, organization_id=org_id, name=host_collection,)['results'][0]
      returndict = {}
      returndict['host_collection_id'] = host_collection_info['id']
      returndict['host_collection_hostcount'] = host_collection_info['total_content_hosts']
      return returndict
   def getHostsFromHostCollection(self,org_id,host_collection):
      hc_info = self.getHostCollectionID(org_id, host_collection)
      hc_id = hc_info['host_collection_id']
      hc_hostcount = hc_info['host_collection_hostcount']
      url = 'katello/api/v2/host_collections/%s/systems' % (hc_id)
      content_hosts = self.getRequest(url,id=hc_id)['results']
      return content_hosts
   def getHostIDsFromHostCollection(self,org_id,host_collection):
      content_hosts = self.getHostsFromHostCollection(org_id,host_collection)
      hc_host_ids = []
      for host in range (len(content_hosts)):
         host_id = content_hosts[host]['id']
         hc_host_ids.append(host_id)
      return hc_host_ids
   def getContentViewVersion(self, content_view_id, env_id):
      
      url = 'katello/api/content_views/{cv_id}/content_view_versions'.format(cv_id = content_view_id)
      cvv_info = self.getRequest(url)['results']
      for cvv in cvv_info:
         envs = cvv['environments']
         for env in envs:
            if env['id'] == env_id:
               return cvv['id']
   # SET:
   def setHostCollectionContentView(self,org_id,content_view_id,environment_id,host_collection):
      # First get the list of host ids in the HC
      hc_host_ids = self.getHostIDsFromHostCollection(org_id,host_collection)
      url = "katello/api/v2/systems/bulk/environment_content_view"
      # works with: 'included': {'ids': [1,2]},
      data = {'organization_id': org_id,
              'included': {'ids': hc_host_ids},
              'content_view_id': content_view_id,
              'environment_id': environment_id}
      print "   setHostCollectionContentView: called with data: '" + str(data) + "'"
      retstat = self.putRequest(url, data)
      return retstat
   def publishContentView(self,org_id,content_view_id,):
      url = "katello/api/content_views/{cvid}/publish".format(cvid = content_view_id)
      data = {'id': content_view_id}
      answer = self.postRequest(url, data)
      task_uuid = answer['id']
      self.checktask(task_uuid)
      return 0
   def promoteContentView(self, environment_id, content_view_version_id):
      url = "katello/api/content_view_versions/{cvvid}/promote".format(cvvid = content_view_version_id)
      data = {'id': content_view_version_id,
              'environment_id': environment_id,
              'force': 'true'}
      answer = self.postRequest(url, data)
      task_uuid = answer['id']
      self.checktask(task_uuid)
      return 0
   def deleteoldContentViewVersions(self, content_view_id, keep):
      url = 'katello/api/content_views/{cv_id}/content_view_versions'.format(cv_id = content_view_id)
      cvv_info = self.getRequest(url)['results']
      cvv_ids = set()
      for cvv in cvv_info:
        if cvv['environments'] == []:
           cvv_ids.add(cvv['id']) 
      for no in range(keep):
         cvv_ids.remove(max(cvv_ids))
      for cvv_id in cvv_ids:
         url = 'katello/api/content_view_versions/{cvvid}'.format(cvvid = cvv_id)
         data = {'id': cvv_id}
         answer = self.deleteRequest(url,data)
         task_uuid = answer['id']
         self.checktask(task_uuid)
      return 0
