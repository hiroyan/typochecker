require 'benchmark'
require_relative '../typochecker.rb'

include SpellingSupport

typochecker = TypoChecker.new

puts Benchmark.measure {
  puts typochecker.check_file(__dir__ + '/test.txt')
}
