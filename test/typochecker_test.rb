# frozen_string_literal: true

require_relative 'test_helper'

class TypocheckerTest < Minitest::Test
  def setup
    @dictionary_file = File.expand_path('../words.txt', __dir__)
    @keyword_file = File.expand_path('../keyword.txt', __dir__)
    @checker = Typochecker::TypoChecker.new(
      dictionary_file: @dictionary_file,
      keyword_file: @keyword_file
    )
  end

  def test_word_variations
    assert_equal %w[studied studying studies], Typochecker::SpellingSupport.word_variations('study')
  end

  def test_parse_words
    assert_equal %w[hello world value json], Typochecker::SpellingSupport.parse_words('Hello world JSON value')
  end

  def test_find_typo_returns_suggestions
    typo = @checker.find_typo('progresive')

    refute_nil typo
    assert_equal 'progresive', typo.word
    assert_includes typo.suggestions, 'progressive'
  end

  def test_find_typo_returns_nil_for_dictionary_word
    assert_nil @checker.find_typo('progressive')
  end

  def test_check_file_reports_line_number_and_suggestion
    result = @checker.check_file(File.expand_path('test.txt', __dir__))

    assert_includes result, '7: progresive is possibly typo.'
    assert_includes result, 'Did you mean: progressive'
  end
end
