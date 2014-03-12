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
    class SakuraDiskDelete < Knife

      include Knife::SakuraBase

      banner "knife sakura disk delete (options)"

      option :id,
        :short => "-i ID",
        :long => "--id ID",
        :description => "The id of disk"

      def run
        validate!

        delete_disk_id = locate_config_value( :id )

        if delete_disk_id == nil
          puts 'Error. Missing disk id (-i) option.'
        else

          volume = Fog::Volume.new(
            :provider => 'SakuraCloud',
            :sakuracloud_api_token => Chef::Config[:knife][:sakuracloud_api_token],
            :sakuracloud_api_token_secret => Chef::Config[:knife][:sakuracloud_api_token_secret],
          )

          begin
            response = volume.disks.delete( delete_disk_id )
            if response
              puts "succeeded."
            else
              puts "failed."
            end
          rescue Exception
            body = Fog::JSON.decode( $!.response.body )
            puts "#{body['status']}: #{body['error_msg']}"
          end
        end
      end
    end
  end
end
