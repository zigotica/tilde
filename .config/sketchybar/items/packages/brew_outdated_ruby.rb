#!/usr/bin/env ruby
# Ruby wrapper to run brew outdated with proper $CHILD_STATUS initialization

# Ensure $CHILD_STATUS is initialized by running a command first
# This is critical - Homebrew's hardware detection relies on $CHILD_STATUS being set
`getconf _NPROCESSORS_ONLN > /dev/null 2>&1`

# Set environment variables
ENV['HOMEBREW_NO_AUTO_UPDATE'] = '1'
ENV['HOMEBREW_NO_INSTALL_CLEANUP'] = '1'
ENV['HOMEBREW_NO_ENV_HINTS'] = '1'
ENV['HOMEBREW_NO_ANALYTICS'] = '1'
ENV['PATH'] = '/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin'

# Run brew outdated --json and output the result
puts `#{ENV['PATH'].split(':').find { |p| File.exist?("#{p}/brew") } || '/opt/homebrew/bin'}/brew outdated --json 2>&1`
