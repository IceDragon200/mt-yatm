#!/usr/bin/env ruby
require 'fileutils'

build_root = '/home/icy/Games/minecraft/MyMods/YATM/resources/build/blocks/'
target_directory = File.expand_path('textures', __dir__)

FileUtils.rm_rf target_directory
FileUtils.mkdir target_directory

Dir.glob(build_root + '**/*.png') do |filename|
  next if filename =~ /\.legacy\//
  basename = filename.gsub(build_root, '')
  next if basename.start_with?('common/')
  newname = 'yatm_' + basename.gsub('/', '_')

  target_filename = File.join(target_directory, newname)
  FileUtils::Verbose.cp filename, target_filename
end
