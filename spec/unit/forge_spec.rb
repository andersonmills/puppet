require 'spec_helper'
require 'puppet/forge'
require 'net/http'
require 'puppet/module_tool'

describe Puppet::Forge do
  let(:http_response) do
  <<-EOF
    {
      "pagination": {
        "limit": 1,
        "offset": 0,
        "first": "/v3/modules?limit=1&offset=0",
        "previous": null,
        "current": "/v3/modules?limit=1&offset=0",
        "next": null,
        "total": 1832
      },
      "results": [
        {
          "uri": "/v3/modules/puppetlabs-bacula",
          "name": "bacula",
          "downloads": 640274,
          "created_at": "2011-05-24 18:34:58 -0700",
          "updated_at": "2013-12-03 15:24:20 -0800",
          "owner": {
            "uri": "/v3/users/puppetlabs",
            "username": "puppetlabs",
            "gravatar_id": "fdd009b7c1ec96e088b389f773e87aec"
          },
          "current_release": {
            "uri": "/v3/releases/puppetlabs-bacula-0.0.2",
            "module": {
              "uri": "/v3/modules/puppetlabs-bacula",
              "name": "bacula",
              "owner": {
                "uri": "/v3/users/puppetlabs",
                "username": "puppetlabs",
                "gravatar_id": "fdd009b7c1ec96e088b389f773e87aec"
              }
            },
            "version": "0.0.2",
            "metadata": {
              "types": [],
              "license": "Apache 2.0",
              "checksums": { },
              "version": "0.0.2",
              "source": "git://github.com/puppetlabs/puppetlabs-bacula.git",
              "project_page": "https://github.com/puppetlabs/puppetlabs-bacula",
              "summary": "bacula",
              "dependencies": [ ],
              "author": "puppetlabs",
              "name": "puppetlabs-bacula"
            },
            "tags": [
              "backup",
              "bacula"
            ],
            "file_uri": "/v3/files/puppetlabs-bacula-0.0.2.tar.gz",
            "file_size": 67586,
            "file_md5": "bbf919d7ee9d278d2facf39c25578bf8",
            "downloads": 565041,
            "readme": "",
            "changelog": "",
            "license": "",
            "created_at": "2013-05-13 08:31:19 -0700",
            "updated_at": "2013-05-13 08:31:19 -0700",
            "deleted_at": null
          },
          "releases": [
            {
              "uri": "/v3/releases/puppetlabs-bacula-0.0.2",
              "version": "0.0.2"
            },
            {
              "uri": "/v3/releases/puppetlabs-bacula-0.0.1",
              "version": "0.0.1"
            }
          ],
          "homepage_url": "https://github.com/puppetlabs/puppetlabs-bacula",
          "issues_url": "https://projects.puppetlabs.com/projects/bacula/issues"
        }
      ]
    }
  EOF
  end

  let(:search_results) do
    PSON.parse(http_response)['results'].map do |hash|
      hash.merge(
        "author" => "puppetlabs",
        "name" => "bacula",
        "tag_list" => ["backup", "bacula"],
        "full_name" => "puppetlabs/bacula",
        "version" => "0.0.2",
        "project_url" => "https://github.com/puppetlabs/puppetlabs-bacula",
        "desc" => "bacula"
      )
    end
  end

  let(:forge) { Puppet::Forge.new }

  def repository_responds_with(response)
    Puppet::Forge::Repository.any_instance.stubs(:make_http_request).returns(response)
  end

  it "returns a list of matches from the forge when there are matches for the search term" do
    repository_responds_with(stub(:body => http_response, :code => '200'))
    forge.search('bacula').should == search_results
  end

  context "when the connection to the forge fails" do
    before :each do
      repository_responds_with(stub(:body => '{}', :code => '404', :message => "not found"))
    end

    it "raises an error for search" do
      expect { forge.search('bacula') }.to raise_error Puppet::Forge::Errors::ResponseError, "Could not execute operation for 'bacula'. Detail: 404 not found."
    end

    it "raises an error for fetch" do
      expect { forge.fetch('puppetlabs/bacula') }.to raise_error Puppet::Forge::Errors::ResponseError, "Could not execute operation for 'puppetlabs/bacula'. Detail: 404 not found."
    end
  end

  context "when the API responds with an error" do
    before :each do
      repository_responds_with(stub(:body => '{"error":"invalid module"}', :code => '410', :message => "Gone"))
    end

    it "raises an error for fetch" do
      expect { forge.fetch('puppetlabs/bacula') }.to raise_error Puppet::Forge::Errors::ResponseError, "Could not execute operation for 'puppetlabs/bacula'. Detail: 410 Gone."
    end
  end

  describe "#fetch_release" do
    let(:module_response) do
      <<-JSON
      {
        "uri": "/v3/modules/puppetlabs-bacula",
        "name": "bacula",
        "downloads": 1786,
        "created_at": "2011-12-12 18:23:52 -0800",
        "updated_at": "2014-04-08 12:56:26 -0700",
        "supported": false,
        "owner": {
          "uri": "/v3/users/puppetlabs",
          "username": "puppetlabs",
          "gravatar_id": "fdd009b7c1ec96e088b389f773e87aec"
        },
        "current_release": {
          "uri": "/v3/releases/puppetlabs-bacula-0.0.2",
          "module": {
            "uri": "/v3/modules/puppetlabs-bacula",
            "name": "bacula",
            "owner": {
              "uri": "/v3/users/puppetlabs",
              "username": "puppetlabs",
              "gravatar_id": "fdd009b7c1ec96e088b389f773e87aec"
            }
          },
          "version": "0.0.2",
          "metadata": {
            "description": "This module manages Bacula, a complete backup solution",
            "source": "http://github.com/puppetlabs/puppetlabs-bacula",
            "summary": "This module manages a bacula infrastructure",
            "author": "Puppet Labs",
            "dependencies": [
              {
                "version_requirement": ">= 2.2.0",
                "name": "puppetlabs/stdlib"
              },
              {
                "version_requirement": ">= 0.0.1",
                "name": "puppetlabs/mysql"
              },
              {
                "version_requirement": ">= 0.0.1",
                "name": "puppetlabs/sqlite"
              }
            ],
            "project_page": "http://github.com/puppetlabs/puppetlabs-bacula",
            "types": [

            ],
            "license": "Apache",
            "version": "0.0.2",
            "name": "puppetlabs-bacula"
          },
          "tags": [
            "backup",
            "bacula"
          ],
          "supported": false,
          "file_uri": "/v3/files/puppetlabs-bacula-0.0.2.tar.gz",
          "file_size": 15893,
          "file_md5": "1b8b32a6e7d9ff805d17ba5d606f1931",
          "downloads": 1466,
          "readme": null,
          "changelog": null,
          "license": null,
          "created_at": "2011-12-15 17:43:10 -0800",
          "updated_at": "2011-12-15 17:43:10 -0800",
          "deleted_at": null
        },
        "releases": [
          {
            "uri": "/v3/releases/puppetlabs-bacula-0.0.2",
            "version": "0.0.2",
            "supported": false
          },
          {
            "uri": "/v3/releases/puppetlabs-bacula-0.0.1",
            "version": "0.0.1",
            "supported": false
          }
        ],
        "homepage_url": "http://github.com/puppetlabs/puppetlabs-bacula",
        "issues_url": "https://tickets.puppetlabs.com"
      }
      JSON
    end

    let(:release_response) do
      <<-JSON
      {
      "uri": "/v3/releases/puppetlabs-bacula-0.0.1",
      "module": {
        "uri": "/v3/modules/puppetlabs-bacula",
        "name": "bacula",
        "owner": {
          "uri": "/v3/users/puppetlabs",
          "username": "puppetlabs",
          "gravatar_id": "fdd009b7c1ec96e088b389f773e87aec"
        }
      },
      "version": "0.0.1",
      "metadata": {
        "description": "This module manages Bacula, a complete backup solution",
        "source": "http://github.com/puppetlabs/puppetlabs-bacula",
        "summary": "This module manages a bacula infrastructure",
        "author": "Puppet Labs",
        "dependencies": [
          {
            "version_requirement": ">= 2.2.0",
            "name": "puppetlabs/stdlib"
          }
        ],
        "project_page": "http://github.com/puppetlabs/puppetlabs-bacula",
        "types": [

        ],
        "license": "Apache",
        "version": "0.0.1",
        "name": "puppetlabs-bacula"
      },
      "tags": [
      "backup",
      "bacula"
      ],
      "supported": false,
      "file_uri": "/v3/files/puppetlabs-bacula-0.0.1.tar.gz",
      "file_size": 12789,
      "file_md5": "c29882cf29eff17f18dcb74cc544c200",
      "downloads": 320,
      "readme": null,
      "changelog": null,
      "license": null,
      "created_at": "2011-12-12 18:27:33 -0800",
      "updated_at": "2011-12-12 18:27:33 -0800",
      "deleted_at": null
      }
      JSON
    end

  it "returns a release for the current version when no version is specified" do
    repository_responds_with(stub(:body => module_response, :code => '200'))
    release = forge.fetch_release('puppetlabs-bacula')

    release.should be_a Puppet::Forge::ModuleRelease
    release.name.should == 'puppetlabs-bacula'
    release.version.to_s.should == '0.0.2'
  end

  it "returns a specific release when the version is specified" do
    repository_responds_with(stub(:body => release_response, :code => '200'))
    release = forge.fetch_release('puppetlabs-bacula', '0.0.1')

    release.should be_a Puppet::Forge::ModuleRelease
    release.name.should == 'puppetlabs-bacula'
    release.version.to_s.should == '0.0.1'
  end




  end
end
