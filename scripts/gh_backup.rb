#!/usr/bin/env ruby

require 'rubygems'
require 'net/https'
require 'uri'
require 'json'


# see: https://help.github.com/articles/creating-an-oauth-token-for-command-line-use
# for how to create a Github.com oauth token
TOKEN="token TOKEN"
MODE="owner"
REPO_DIR="github"

uri = URI.parse("https://api.github.com/user/repos")
http = Net::HTTP.new(uri.host, uri.port)
http.use_ssl = true

headers = {
  "Authorization" => TOKEN,
  "type"=> MODE
}

request = Net::HTTP::Get.new(uri.request_uri, headers)

response = http.request(request)
repos = JSON.parse(response.body) # => A string containing the JSON response

repos.each do |repo|
  url = repo["ssh_url"]
  name = repo["name"]
  unless ( Dir.exists?(name) )
    system "git clone --mirror #{url} #{REPO_DIR}/#{name}"
  else
    puts "Repository #{name} already exists!"
  end
end
