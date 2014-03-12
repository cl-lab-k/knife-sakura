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
    class SakuraDiskCreate < Knife

      include Knife::SakuraBase

      banner "knife sakura disk create (options)"

      option :name,
        :short => "-n NAME",
        :long => "--name NAME",
        :description => "The name of disk"

      option :plan,
        :short => "-p PLAN",
        :long => "--plan PLAN",
        :description => "The plan id for the disk"

      option :source_archive,
        :short => "-s SOURCE_ARCHIVE",
        :long => "--source-archive SOURCE_ARCHIVE",
        :description => "The source archive id for disk"

      def run
        validate!

        options = {}
        options['name'] = locate_config_value( :name )
        options['plan'] = locate_config_value( :plan )
        options['source_archive'] = locate_config_value( :source_archive )

        if options['name'] == nil
          puts 'Error. Missing disk name (-n) option.'
        elsif options['plan'] == nil
          puts 'Error. Missing plan id (-p) option.'
        elsif options['source_archive'] == nil
          puts 'Error. Missing source_archive id (-s) option.'
        else

          volume = Fog::Volume.new(
            :provider => 'SakuraCloud',
            :sakuracloud_api_token => Chef::Config[:knife][:sakuracloud_api_token],
            :sakuracloud_api_token_secret => Chef::Config[:knife][:sakuracloud_api_token_secret],
          )

          begin
            response = volume.disks.create( options )
            if response.class == Fog::Volume::SakuraCloud::Disk
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
