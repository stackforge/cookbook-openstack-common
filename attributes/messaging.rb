# encoding: UTF-8
#
# Cookbook Name:: openstack-common
# Attributes:: messaging
#
# Copyright 2012-2013, AT&T Services, Inc.
# Copyright 2013, SUSE Linux GmbH
# Copyright 2013-2014, Rackspace US, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# The rabbitmq user's password is stored in an encrypted databag and accessed
# with openstack-common cookbook library's user_password routine.  You are
# expected to create the user, pass, vhost in a wrapper rabbitmq cookbook.
#

# ******************** RabbitMQ Endpoint **************************************
default['openstack']['endpoints']['mq']['host'] = '127.0.0.1'
default['openstack']['endpoints']['mq']['scheme'] = nil
default['openstack']['endpoints']['mq']['port'] = '5672'
default['openstack']['endpoints']['mq']['path'] = nil
default['openstack']['endpoints']['mq']['bind_interface'] = nil

###################################################################
# Services to assign mq attributes for
###################################################################
services = %w{block-storage compute image metering network orchestration}

###################################################################
# Generic default attributes
###################################################################
default['openstack']['mq']['server_role'] = 'os-ops-messaging'
default['openstack']['mq']['service_type'] = 'rabbitmq'
# Note that the openstack:mq:host and openstack:mq:port attributes are being
# deprecated in favor of the mq endpoint and will be removed in a future
# patch set.
default['openstack']['mq']['host'] = default['openstack']['endpoints']['mq']['host']
default['openstack']['mq']['port'] = default['openstack']['endpoints']['mq']['port']
default['openstack']['mq']['user'] = 'guest'
default['openstack']['mq']['vhost'] = '/'

###################################################################
# Default qpid and rabbit values (for attribute assignment below)
###################################################################
qpid_defaults = {
  username: node['openstack']['mq']['user'],
  sasl_mechanisms: '',
  reconnect: true,
  reconnect_timeout: 0,
  reconnect_limit: 0,
  reconnect_interval_min: 0,
  reconnect_interval_max: 0,
  reconnect_interval: 0,
  heartbeat: 60,
  protocol: 'tcp',
  tcp_nodelay: true,
  host: node['openstack']['endpoints']['mq']['host'],
  port: node['openstack']['endpoints']['mq']['port'],
  qpid_hosts: ["#{node['openstack']['endpoints']['mq']['host']}:#{node['openstack']['endpoints']['mq']['port']}"]
}

rabbit_defaults = {
  userid: node['openstack']['mq']['user'],
  vhost: node['openstack']['mq']['vhost'],
  port: node['openstack']['endpoints']['mq']['port'],
  host: node['openstack']['endpoints']['mq']['host'],
  ha: false,
  use_ssl: false
}

###################################################################
# Assign default mq attributes for every service
###################################################################
services.each do |svc|
  default['openstack']['mq'][svc]['service_type'] = node['openstack']['mq']['service_type']
  default['openstack']['mq'][svc]['notification_topic'] = 'notifications'

  case node['openstack']['mq'][svc]['service_type']
  when 'qpid'
    qpid_defaults.each do |key, val|
      default['openstack']['mq'][svc]['qpid'][key.to_s] = val
    end
  when 'rabbitmq'
    rabbit_defaults.each do |key, val|
      default['openstack']['mq'][svc]['rabbit'][key.to_s] = val
    end
  end
end

###################################################################
# Overrides and additional attributes for individual services
###################################################################
# block-storage
default['openstack']['mq']['block-storage']['qpid']['notification_topic'] =
  node['openstack']['mq']['block-storage']['notification_topic']
default['openstack']['mq']['block-storage']['rabbit']['notification_topic'] =
  node['openstack']['mq']['block-storage']['notification_topic']

# image
default['openstack']['mq']['image']['notifier_strategy'] = 'noop'
default['openstack']['mq']['image']['notification_topic'] = 'glance_notifications'
default['openstack']['mq']['image']['qpid']['notification_topic'] =
  node['openstack']['mq']['image']['notification_topic']
default['openstack']['mq']['image']['rabbit']['notification_topic'] =
  node['openstack']['mq']['image']['notification_topic']

# network
# AMQP topics used for openstack notifications, can be comma-separated values
default['openstack']['mq']['network']['notification_topics'] = 'notifications'
