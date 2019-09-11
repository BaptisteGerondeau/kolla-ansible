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

from ansible import errors


MyError = errors.AnsibleFilterError


class FilterModule(object):
    """IP address filters (p2)"""

    def filters(self):
        return {
            'put_address_in_context': put_address_in_context,
        }


def put_address_in_context(address, addr_context):
    """puts address in context

    :param address: the address to contextify
    :param addr_context: describes context in which the address appears,
                         either 'url' or 'memcache',
                         affects only IPv6 addresses format
    :returns: string with address in proper context
    """

    if addr_context not in ['url', 'memcache']:
        raise MyError('Unknown context')

    if ':' in address:  # must be IPv6 raw address
        if addr_context == 'url':
            return '[%s]' % address
        elif addr_context == 'memcache':
            return 'inet6:[%s]' % address

        return address
    else:
        return address
