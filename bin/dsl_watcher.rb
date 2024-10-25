#!/usr/bin/env ruby
# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)

require 'klue/langcraft'

BASE_PATH = ARGV[0] || '/Users/davidcruwys/dev/appydave/klueless'

DSLFolderWatcher.watch(BASE_PATH)
