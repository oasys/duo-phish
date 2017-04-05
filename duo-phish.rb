#!/usr/bin/env ruby

require 'optparse'
require 'duo_api'
require 'json'

txs   = []
users = []
opt   = { :type => 'Login', }
OptionParser.new do |opts|
  opts.banner = "Usage: #{File.basename($0)} [options] [user...]|[-f file]"
  opts.on('-i', '--ikey IKEY', 'Integration Key') do |ikey|
    opt[:ikey] = ikey
  end
  opts.on('-s', '--skey SKEY', 'Secret Key') do |skey|
    opt[:skey] = skey
  end
  opts.on('-H', '--host HOST', 'API host') do |host|
    opt[:host] = host
  end
  opts.on('-f', '--file [FILE]', 'filename (one user per line)') do |file|
    opt[:file] = file
  end
  opts.on('-t', '--type [FILE]', 'Request type in push') do |type|
    opt[:type] = type
  end
  opts.on("-h","--help","help") do
    puts opts
    exit
  end
end.parse!

# get list of users from file or commandline
if opt[:file] then
  users = IO.readlines(opt[:file]).map(&:chomp)
else
  users = ARGV
end
abort "exiting: must specify at least one user" unless users.length > 0

query = { factor: 'push', device: 'auto', async: 1, type: opt[:type] }
duo   = DuoApi.new opt[:ikey], opt[:skey], opt[:host]
users.each do |user|
  resp = duo.request 'POST', '/auth/v2/auth', query.merge({ username: user })
  if resp.code == '200' then
    txs.push({ user: user, id: JSON.parse(resp.body)['response']['txid'] })
  else
    message = JSON.parse(resp.body)['message']
    detail  = JSON.parse(resp.body)['message_detail']
    txs.push({ user: user, err: "#{message} (#{detail})" })
  end
end

begin loop
  puts
  puts "Hit <enter> to query responses, Ctrl-c to quit."
  $stdin.gets
  puts "username             result"
  puts "-------------------- --------------------------------"

  txs.each do |tx|
    if tx[:err] then
      result = tx[:err]
    else
      resp = duo.request 'GET', '/auth/v2/auth_status', { txid: tx[:id] }
      if resp.code == '200' then
        result = JSON.parse(resp.body)['response']['status']
      else
        result = JSON.parse(resp.body)['response']['message']
      end
    end
    printf "%-20s %s\n", tx[:user], result
  end

rescue Interrupt
  exit
end while 1
