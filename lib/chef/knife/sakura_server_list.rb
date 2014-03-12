#
# Author:: HIGUCHI Daisuke (<d-higuchi@creationline.com>)
# Copyright:: Copyright (c) 2014 CREATIONLINE, INC.
# License:: Apache License, Version 2.0
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

require 'chef/knife/sakura_base'

class Chef
  class Knife
    class SakuraServerList < Knife

      include Knife::SakuraBase

      banner "knife sakura server list (options)"

      def run
        validate!

        server_list = [
          ui.color('ID', :bold),
          ui.color('Name', :bold),
          ui.color('Status', :bold),
          ui.color('Created at', :bold),
        ]
        connection.servers.sort_by(&:id).each do |server|
          server_list << server.id.to_s
          server_list << server.name
          server_list << server.attributes[:instance]['Status']
          server_list << server.attributes['CreatedAt']
        end
        puts ui.list(server_list, :columns_across, 4)
      end
    end
  end
end
