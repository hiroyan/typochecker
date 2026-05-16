# frozen_string_literal: true

# 旧来の直接実行・require 利用との互換用入口。
require_relative 'lib/typochecker'

SpellingSupport = Typochecker::SpellingSupport unless defined?(SpellingSupport)
TypoChecker = Typochecker::TypoChecker unless defined?(TypoChecker)

if $PROGRAM_NAME == __FILE__
  load File.expand_path('exe/typochecker', __dir__)
end
