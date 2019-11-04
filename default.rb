#
# Cookbook:: nginx-server
# Recipe:: default
#
# Copyright:: 2019, The Authors, All Rights Reserved.

package 'git'
package 'tree'

package 'nginx' do
  action :install
end

service 'nginx' do
  action [ :enable, :start ]
end 
   
  