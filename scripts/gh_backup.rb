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


repos = []
begin
  request = Net::HTTP::Get.new(uri.request_uri, headers)
  response = http.request(request)
  repos += JSON.parse(response.body) # => A string containing the JSON response
  linkhdr = response["Link"]
  if linkhdr
    nextpage = linkhdr.split(", ").find { |x| x =~/rel="next"/}
    if nextpage
       uri= URI.parse(nextpage.split("; ").first.tr('<>', ''))
    end
  end
end until nextpage.nil?

repos.each do |repo|
  url = repo["clone_url"]
  localdir=File.join(REPO_DIR,File.basename(url))
  name = repo["name"]
  unless ( Dir.exists?(localdir) )
    system "git clone --mirror #{url} #{localdir}"
  else
    system "git --git-dir=#{localdir} remote update"
  end
end
