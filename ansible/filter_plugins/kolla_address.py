# -*- coding: utf-8 -*-
#
# Copyright 2019 Radosław Piliszek (yoctozepto)
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

from jinja2.filters import contextfilter
from jinja2.runtime import Undefined

from ansible import errors


MyError = errors.AnsibleFilterError


class FilterModule(object):
    """IP address filters"""

    def filters(self):
        return {
            'kolla_address': kolla_address,
        }


@contextfilter
def kolla_address(context, network_name, hostname=None, addr_context=None):
    """returns IP address on the requested network

    The output is affected by '<network_name>_*' variables:
    '<network_name>_interface' sets the interface to obtain address for.
    '<network_name>_af' controls the address family (ipv4/ipv6).

    :param context: Jinja2 Context
    :param network_name: string denoting the name of the network to get IP
                         address for, e.g. 'api'
    :param hostname: to override host which address is retrieved for
    :param addr_context: describes context in which the address appears,
                         either 'url' or 'memcache',
                         affects only IPv6 addresses format
    :returns: string with IP address
    """

    # NOTE(yoctozepto): watch out as Jinja2 'context' behaves not exactly like
    # the python 'dict' (but mimics it most of the time)
    # for example it returns a special object of type 'Undefined' instead of
    # 'None' or value specified as default for 'get' method
    # 'HostVars' shares this behavior

    if hostname is None:
        hostname = context.get('inventory_hostname')
        if isinstance(hostname, Undefined):
            raise MyError("'inventory_hostname' variable is unavailable")

    if addr_context is not None and addr_context not in ['url', 'memcache']:
        raise MyError("Unknown 'addr_context' given: %s" % addr_context)

    hostvars = context.get('hostvars')
    if isinstance(hostvars, Undefined):
        raise MyError("'hostvars' variable is unavailable")

    del context  # remove for sanity

    host = hostvars.get(hostname)
    if isinstance(host, Undefined):
        raise MyError("'%s' not in 'hostvars'" % hostname)

    del hostvars  # remove for sanity (no 'Undefined' beyond this point)

    interface_name = host.get('%s_interface' % network_name)
    if interface_name is None:
        raise MyError("Interface name undefined for network '%s'" %
                      network_name)

    af = host.get('%s_af' % network_name)
    if af is None:
        raise MyError("AF undefined for network '%s'" % network_name)
    if af not in ['ipv4', 'ipv6']:
        raise MyError("Unknown AF '%s'" % af)

    interface = host.get('ansible_%s' % interface_name)
    if interface is None:
        raise MyError("Unknown interface '%s' on host '%s'" %
                      (interface_name, hostname))

    af_interface = interface.get(af)
    if af_interface is None:
        raise MyError("AF '%s' undefined on interface '%s' for host: '%s'" %
                      (af, interface_name, hostname))

    if af == 'ipv4':
        address = af_interface.get('address')
    elif af == 'ipv6':
        # ipv6 has no concept of a secondary address
        # prefix 128 is the default from keepalived
        # it needs to be excluded here
        global_ipv6_addresses = [x for x in af_interface if
                                 x['scope'] == 'global' ]
        if global_ipv6_addresses:
            address = global_ipv6_addresses[0]['address']
        else:
            address = None

    if address is None:
        raise MyError("Address undefined on interface '%s' "
                      "using AF '%s' for host '%s'" %
                      (interface_name, af, hostname))

    if af == 'ipv4':
        return address
    elif af == 'ipv6':
        if addr_context is None:
            return address
        elif addr_context == 'url':
            return '[%s]' % address
        elif addr_context == 'memcache':
            return 'inet6:[%s]' % address
