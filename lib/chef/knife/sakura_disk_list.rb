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
    class SakuraDiskList < Knife

      include Knife::SakuraBase

      banner "knife sakura disk list (options)"

      def run
        validate!

        volume = Fog::Volume.new(
          :provider => 'SakuraCloud',
          :sakuracloud_api_token => Chef::Config[:knife][:sakuracloud_api_token],
          :sakuracloud_api_token_secret => Chef::Config[:knife][:sakuracloud_api_token_secret],
        )

        disk_list = [
          ui.color('ID', :bold),
          ui.color('Name', :bold),
          ui.color('Plan', :bold),
          ui.color('Size', :bold),
        ]
        volume.disks.sort_by(&:id).each do |disk|
          disk_list << disk.id.to_s
          disk_list << disk.name
          disk_list << disk.plan['Name']
          disk_list << disk.size_mb.to_s
        end
        puts ui.list(disk_list, :columns_across, 4)
      end
    end
  end
end
