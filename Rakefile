#!/usr/bin/env rake
require 'cocoapods'
require 'git'

PROJECT_DIR = 'Lock'
VERSION_FILE_PATH = 'Pod/version'

class Semver
  def initialize(args)
    @major = args[:major].to_i
    @minor = args[:minor].to_i
    @patch = args[:patch].to_i
  end
  
  def to_s
    "#{@major}.#{@minor}.#{@patch}"
  end

  def next(version=:patch)
    args = {
      major: @major,
      minor: @minor,
      patch: @patch
    }
    args[:major] = @major + 1 if version == :major
    args[:minor] = @minor + 1 if version == :minor
    args[:patch] = @patch + 1 if version == :patch
    args[:minor] = 0 if version == :major
    args[:patch] = 0 if version == :major or version == :minor
    Semver.new args
  end

  def self.from_file(file_path)
    version_string = File.read(file_path)
    parts = version_string.split '.'
    Semver.new major: parts[0], minor: parts[1], patch: parts[2]
  end
end

def make_release(version)
  version = Semver.from_file(VERSION_FILE_PATH).next(version)
  puts "Bump version to #{version.to_s}"
  File.open(VERSION_FILE_PATH, 'w') {|f| f.write(version.to_s) }
  Rake::Task['pod:sync'].reenable
  Rake::Task['pod:sync'].invoke
  g = Git.init
  g.add ['Lock/Podfile.lock', 'Pod/version']
  g.commit "Release #{version.to_s}"
  g.add_tag(version.to_s)
end

namespace :pod do
  task :init do
    installer = Pod::Command.parse(['install', "--project-directory=#{PROJECT_DIR}"])
    installer.validate!
    installer.run()
  end

  task :sync do
    installer = Pod::Command.parse(['update', 'Lock', "--project-directory=#{PROJECT_DIR}"])
    installer.validate!
    installer.run()
  end
end

namespace :release do

  task :patch do
    make_release :patch
  end

  task :minor do
    make_release :minor
  end

  task :major do
    make_release :major
  end

end

task :default => 'pod:sync'

