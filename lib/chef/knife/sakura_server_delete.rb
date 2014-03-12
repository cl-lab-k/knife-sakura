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
    class SakuraServerDelete < Knife

      include Knife::SakuraBase

      banner "knife sakura server delete (options)"

      option :id,
        :short => "-i ID",
        :long => "--id ID",
        :description => "The id of server"

      option :force,
        :long => "--force",
        :description => "Delete server forcedly",
        :boolean => true,
        :default => false

      option :with_disk,
        :long => "--with-disk DISK[,DISK...]",
        :description => "Delete disk atteched the server"

      def run
        validate!

        options = {}
        options[:id] = locate_config_value( :id )
        options[:force] = locate_config_value( :force )

        if options[:id] == nil
          puts 'Error. Missing server id (-i) option.'
        else

          begin
            target = connection.servers.find { |server|
              server.id == options[:id]
            }
            if target == nil
              puts "Error. Not found server id #{options[:id]}."
            else
              response = target.delete( options )
              if response
                puts "succeeded."
              else
                puts "failed."
              end
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
