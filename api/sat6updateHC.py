#!/usr/bin/env python

import sys, getopt
import json
import requests
import argparse
import Sat6APIUtils

def parse_options():
   parser = argparse.ArgumentParser()
   basic_group = parser.add_argument_group("Basic Options")
   basic_group.add_argument("-o", "--org-label", dest="org", required=True,
                            help="organization label")
   basic_group.add_argument("-cv", "--content-view", dest="content_view", required=True,
                            help="content view name")
   basic_group.add_argument("--promote-from-env", dest="from_env",
                            help="environment to promote from")
   basic_group.add_argument("--promote-to-env", dest="to_env",
                            help="environment to promote to")
   basic_group.add_argument("--create-new-version", dest="new_cvv", action="store_true",
                            default=False, help="create new Content-View Version")
   parser.add_argument_group(basic_group)
   cleanup_group = parser.add_argument_group("Cleanup Options")
   cleanup_group.add_argument("--cleanup", dest="cleanup", action="store_true",
                            default=False, help="Delete all old Content View versions but one")
   cleanup_group.add_argument("--keep", dest="keep", type=int,
                            help="number of Content View Version without an environment to keep (only use with --cleanup)")
   parser.add_argument_group(cleanup_group)
   options = parser.parse_args()
   if (options.new_cvv and options.to_env):
      parser.error("--create-new-version cannot be used with --promote-to-env")
   if (options.new_cvv and options.from_env):
      parser.error("--promote-from-env cannot be used with --create-new-version")
   return options

# Main
def main():
   options = parse_options()
   # Establish API Connection to Satellite
   sat6conn = Sat6APIUtils.Sat6APIUtils()
   # Obtain IDs
   org_id = sat6conn.getOrganizationIDByName(options.org)
   content_view_id = sat6conn.getCVIDbyName(org_id,options.content_view)
   if options.new_cvv:
      sat6conn.publishContentView(org_id,content_view_id)
   elif options.cleanup:
      sat6conn.deleteoldContentViewVersions(content_view_id, options.keep) 
   else:
      # Promote current dev version to prod
      from_env_id = sat6conn.getLVEnvIDbyName(org_id,options.from_env)
      to_env_id = sat6conn.getLVEnvIDbyName(org_id,options.to_env)
      from_cvv_id = sat6conn.getContentViewVersion(content_view_id,from_env_id) 
      sat6conn.promoteContentView(to_env_id,from_cvv_id)

# call main
if __name__ == "__main__":
   main()
