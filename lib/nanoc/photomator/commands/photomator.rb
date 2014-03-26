# encoding: utf-8

usage       'photomator task [options] [arguments]'
summary     'execute photomator task'
description <<-EOS
Start a photomator task.
EOS

flag   :h,  :help,  'show help for this command' do |value, cmd|
  puts cmd.help
  exit 0
end