Knife Sakura
============
[![Gem Version](https://badge.fury.io/rb/knife-sakura.png)](http://badge.fury.io/rb/knife-sakura)
[![Build Status](https://travis-ci.org/cl-lab-k/knife-sakura.png?branch=master)](https://travis-ci.org/cl-lab-k/knife-sakura)
[![Dependency Status](https://gemnasium.com/cl-lab-k/knife-sakura.png)](https://gemnasium.com/cl-lab-k/knife-sakura)

This is the Knife plugin for Sakura Cloud. This plugin gives knife the ability to create, bootstrap, and manage Sakura Cloud instances.


Installation
------------
If you're using bundler, simply add Chef and Knife Sakura to your `Gemfile`:

```ruby
gem 'chef'
gem 'knife-sakura'
```

If you are not using bundler, you can install the gem manually. Be sure you are running Chef 0.10.10 or higher, as earlier versions do not support plugins.

    $ gem install chef

This plugin is distributed as a Ruby Gem. To install it, run:

    $ gem install knife-sakura

Depending on your system's configuration, you may need to run this command with root privileges.


Configuration
-------------
In order to communicate with the Sakura Cloud API you will have to tell Knife about your Sakura Cloud Access Token and Secret. The easiest way to accomplish this is to create some entries in your `knife.rb` file:

```ruby
knife[:sakuracloud_api_token] = "Your Sakura Cloud Access Token"
knife[:sakuracloud_api_token_secret] = "Your Sakura Cloud Access Token Secret"
```

If your `knife.rb` file will be checked into a SCM system (ie readable by others) you may want to read the values from environment variables:

```ruby
knife[:sakuracloud_api_token] = ENV['SAKURACLOUD_API_TOKEN']
knife[:sakuracloud_api_token_secret] = ENV['SAKURACLOUD_API_TOKEN_SECRET']
```

You also have the option of passing your Sakura Cloud API Access Token/Secret into the individual knife subcommands using the `-A` (or `--sakuracloud-api-token`) `-K` (or `--sakuracloud-api-token-secret`) command options

```bash
# provision a new 1Core-1GB Ubuntu 12.04 webserver
$ knife sakura server create -r 'role[webserver]' --server-plan 1001 --disk-plan 4 --source-archive 112500463685 -x ubuntu -i 'Your SSH Key ID' --sakuracloud-ssh-key 'Your SSH Pulic Key' -A 'Your Sakura Cloud Access Token' -K "Your Sakura Cloud Access Secret"
```

If you are working with Sakura Cloud's command line tools, there is a good
chance you already have a file with these keys somewhere in this format:

    {
      "apiRoot": "https://secure.sakura.ad.jp/cloud/zone/is1a/api/cloud/1.1/",
      "accessToken": "Your Sakura Cloud Access Token",
      "accessTokenSecret": "Your Sakura Cloud Access Secret"
    }
        
In this case, you can point the <tt>.sacloudcfg.json</tt> option to
this file in your <tt>knife.rb</tt> file, like so:
        
    knife[:sakuracloud_credential_file] = "/path/to/credentials/file/in/above/format"


Subcommands
-----------
This plugin provides the following Knife subcommands. Specific command options can be found by invoking the subcommand with a `--help` flag


#### `knife sakura server create`
Provisions a new server in the Sakura Cloud and then perform a Chef bootstrap
(using the SSH). The goal of the bootstrap is to get Chef installed on the target system so it can run Chef Client with a Chef Server. The main assumption is a baseline OS installation exists (provided by the provisioning). It is primarily intended for Chef Client systems that talk to a Chef server.  The examples below create Linux instances:

    # Create some instances -- knife configuration contains the Sakura Cloud credentials

    # A Linux instance via ssh
    knife sakura server create --server-plan 1001 --disk-plan 4 --source-archive 112500463685 --ssh-user ubuntu --identity-file 'Your SSH Key ID' --sakuracloud-ssh-key 'Your SSH Pulic Key'

#### `knife sakura server delete`
Deletes an existing server in the currently configured Sakura Cloud account. **By default, this does not delete the associated node and client objects from the Chef server.**

#### `knife sakura server list`
Outputs a list of all servers in the currently configured Sakura Cloud account. **Note, this shows all instances associated with the account, some of which may not be currently managed by the Chef server.**

License and Authors
-------------------
- Author:: HIGUCHI Daisuke (<d-higuchi@creationline.com>)

```text
Copyright 2014 CREATIONLINE, INC.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```
