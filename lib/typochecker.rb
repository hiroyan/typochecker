# frozen_string_literal: true

require_relative 'typochecker/version'
require_relative 'typochecker/spelling_support'
require_relative 'typochecker/typo_checker'

# Levenshtein 距離を使って英単語の typo 候補を検出するライブラリ。
module Typochecker
  module_function

  def default_dictionary_file
    File.expand_path('../words.txt', __dir__)
  end
end
