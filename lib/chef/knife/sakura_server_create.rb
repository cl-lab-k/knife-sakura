#
# Author:: HIGUCHI Daisuke (<d-higuchi@creationline.com>)
# Copyright:: Copyright (c) 2014 CREATIONLINE, INC.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License"); # you may not use this file except in compliance with the License.
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
    class SakuraServerCreate < Knife

      include Knife::SakuraBase


      deps do
        require 'fog'
        require 'readline'
        require 'chef/json_compat'
        require 'chef/knife/bootstrap'
        Chef::Knife::Bootstrap.load_deps
      end

      banner "knife sakura server create (options)"

      #
      # sakura specific
      #
      option :name,
        :short => "-n NAME",
        :long => "--name NAME",
        :description => "The name of server"

      option :serverplan,
        :long => "--server-plan SERVER_PLAN_ID",
        :description => "The plan id for the server"

      option :diskplan,
        :long => "--disk-plan DISK_PLAN_ID",
        :description => "The plan id for the plan"

      option :sourcearchive,
        :long => "--source-archive SOURCE_ARCHIVE_ID",
        :description => "The source archive id for the disk"

      option :boot,
        :long => "--[no-]boot",
        :description => "Boot server immediately, enabled by default.",
        :boolean => true,
        :default => true

      option :sakuracloud_ssh_key,
        :short => "-S KEY",
        :long => "--sakuracloud-ssh-key KEY",
        :description => "The SakuraCloud SSH key id",
        :proc => Proc.new { |key| Chef::Config[:knife][:sakuracloud_ssh_key] = key }

      #
      # chef
      #
      option :chef_node_name,
        :short => "-N NAME",
        :long => "--node-name NAME",
        :description => "The Chef node name for your new node",
        :proc => Proc.new { |key| Chef::Config[:knife][:chef_node_name] = key }

      option :ssh_user,
        :short => "-x USERNAME",
        :long => "--ssh-user USERNAME",
        :description => "The ssh username",
        :default => "root"

      option :ssh_password,
        :short => "-P PASSWORD",
        :long => "--ssh-password PASSWORD",
        :description => "The ssh password"

      option :ssh_port,
        :short => "-p PORT",
        :long => "--ssh-port PORT",
        :description => "The ssh port",
        :default => "22",
        :proc => Proc.new { |key| Chef::Config[:knife][:ssh_port] = key }

      option :ssh_gateway,
        :short => "-w GATEWAY",
        :long => "--ssh-gateway GATEWAY",
        :description => "The ssh gateway server",
        :proc => Proc.new { |key| Chef::Config[:knife][:ssh_gateway] = key }

      option :identity_file,
        :short => "-i IDENTITY_FILE",
        :long => "--identity-file IDENTITY_FILE",
        :description => "The SSH identity file used for authentication"

      option :prerelease,
        :long => "--prerelease",
        :description => "Install the pre-release chef gems"

      option :bootstrap_version,
        :long => "--bootstrap-version VERSION",
        :description => "The version of Chef to install",
        :proc => Proc.new { |v| Chef::Config[:knife][:bootstrap_version] = v }

      option :bootstrap_proxy,
        :long => "--bootstrap-proxy PROXY_URL",
        :description => "The proxy server for the node being bootstrapped",
        :proc => Proc.new { |p| Chef::Config[:knife][:bootstrap_proxy] = p }

      option :distro,
        :short => "-d DISTRO",
        :long => "--distro DISTRO",
        :description => "Bootstrap a distro using a template; default is 'chef-full'",
        :proc => Proc.new { |d| Chef::Config[:knife][:distro] = d },
        :default => "chef-full"

      option :template_file,
        :long => "--template-file TEMPLATE",
        :description => "Full path to location of template to use",
        :proc => Proc.new { |t| Chef::Config[:knife][:template_file] = t },
        :default => false

      option :run_list,
        :short => "-r RUN_LIST",
        :long => "--run-list RUN_LIST",
        :description => "Comma separated list of roles/recipes to apply",
        :proc => lambda { |o| o.split(/[\s,]+/) }

      option :secret,
        :short => "-s SECRET",
        :long => "--secret ",
        :description => "The secret key to use to encrypt data bag item values",
        :proc => lambda { |s| Chef::Config[:knife][:secret] = s }

      option :secret_file,
        :long => "--secret-file SECRET_FILE",
        :description => "A file containing the secret key to use to encrypt data bag item values",
        :proc => lambda { |sf| Chef::Config[:knife][:secret_file] = sf }

      option :json_attributes,
        :short => "-j JSON",
        :long => "--json-attributes JSON",
        :description => "A JSON string to be added to the first run of chef-client",
        :proc => lambda { |o| JSON.parse(o) }

      option :host_key_verify,
        :long => "--[no-]host-key-verify",
        :description => "Verify host key, enabled by default.",
        :boolean => true,
        :default => true

      option :hint,
        :long => "--hint HINT_NAME[=HINT_FILE]",
        :description => "Specify Ohai Hint to be set on the bootstrap target. Use multiple --hint options to specify multiple hints.",
        :proc => Proc.new { |h|
           Chef::Config[:knife][:hints] ||= {}
           name, path = h.split("=")
           Chef::Config[:knife][:hints][name] = path ? JSON.parse(::File.read(path)) : Hash.new
        }

      def run
        $stdout.sync = true

        validate!

        options = {}
        options[:name] = locate_config_value( :name )
        options[:serverplan] = locate_config_value( :serverplan )
        options[:volume] = {
          :diskplan => locate_config_value( :diskplan ),
          :sourcearchive => locate_config_value( :sourcearchive )
        }
        options[:boot] = locate_config_value( :boot )
        options[:sshkey] = locate_config_value( :sakuracloud_ssh_key )

        if options[:name] == nil
          puts 'Error. Missing disk name (-n) option.'
        elsif options[:serverplan] == nil
          puts 'Error. Missing server plan id (--server-plan) option.'
        elsif options[:volume][:diskplan] == nil
          puts 'Error. Missing disk plan id (--disk-plan) option.'
        elsif options[:volume][:sourcearchive] == nil
          puts 'Error. Missing source_archive id (--source-archive) option.'
        else

          begin
            @server = connection.servers.create( options )

            msg_pair("Instance ID", @server.id)
            msg_pair("Server Plan", @server.server_plan['Name'])

            bootstrap_ip_address = @server.interfaces.first['IPAddress']
            msg_pair("Public IP Address", bootstrap_ip_address)

            bootstrap_node(@server, bootstrap_ip_address).run
          rescue Exception
            puts $!.message
            body = Fog::JSON.decode( $!.response.body )
            puts "#{body['status']}: #{body['error_msg']}"
          end
        end
      end # def run

      def bootstrap_node(server, bootstrap_ip_address)
        bootstrap = Chef::Knife::Bootstrap.new
        bootstrap.name_args = [bootstrap_ip_address]
        bootstrap.config[:ssh_user] = config[:ssh_user]
        bootstrap.config[:ssh_port] = config[:ssh_port]
        bootstrap.config[:ssh_gateway] = config[:ssh_gateway]
        bootstrap.config[:identity_file] = config[:identity_file]
        bootstrap.config[:chef_node_name] = locate_config_value(:chef_node_name) || server.name
        bootstrap.config[:use_sudo] = true unless config[:ssh_user] == 'root'
        bootstrap.config[:host_key_verify] = config[:host_key_verify]
        #
        bootstrap.config[:run_list] = config[:run_list]
        bootstrap.config[:bootstrap_version] = locate_config_value(:bootstrap_version)
        bootstrap.config[:distro] = locate_config_value(:distro)
        bootstrap.config[:template_file] = locate_config_value(:template_file)
        bootstrap.config[:environment] = locate_config_value(:environment)
        bootstrap.config[:prerelease] = config[:prerelease]
        bootstrap.config[:first_boot_attributes] = locate_config_value(:json_attributes) || {}
        bootstrap.config[:encrypted_data_bag_secret] = locate_config_value(:encrypted_data_bag_secret)
        bootstrap.config[:encrypted_data_bag_secret_file] = locate_config_value(:encrypted_data_bag_secret_file)
        bootstrap.config[:secret] = locate_config_value(:secret)
        bootstrap.config[:secret_file] = locate_config_value(:secret_file)
        # Modify global configuration state to ensure hint gets set by
        # knife-bootstrap
        Chef::Config[:knife][:hints] ||= {}
        Chef::Config[:knife][:hints]["sakura"] ||= {}
        bootstrap
      end
    end
  end
end
