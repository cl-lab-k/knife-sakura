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
    class SakuraZoneList < Knife

      include Knife::SakuraBase

      banner "knife sakura zone list (options)"

      def run
        validate!

        zone_list = [
          ui.color('ID', :bold),
          ui.color('Name', :bold),
          ui.color('Description', :bold),
        ]
        connection.zones.sort_by(&:id).each do |zone|
          zone_list << zone.id.to_s
          zone_list << zone.name
          zone_list << zone.description
        end
        puts ui.list(zone_list, :columns_across, 3)
      end
    end
  end
end
