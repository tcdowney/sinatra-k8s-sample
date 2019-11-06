# frozen_string_literal: true

require 'rubygems'
require 'bundler'

Bundler.require
$stdout.sync = true

require './belafonte'
run Belafonte
