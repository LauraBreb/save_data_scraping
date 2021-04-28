require 'bundler'
Bundler.require

$:.unshift File.expand_path("./../lib", __FILE__)
require 'app/scrapper'

my_scrapping = Scrapper.new

my_scrapping.perform

