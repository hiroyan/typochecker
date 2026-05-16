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
    assert_equal 'progressive', typo.suggestions.first
  end

  def test_find_typo_returns_nil_for_dictionary_word
    assert_nil @checker.find_typo('progressive')
  end

  def test_check_file_reports_line_number_and_suggestion
    result = @checker.check_file(File.expand_path('test.txt', __dir__))

    assert_includes result, '7: progresive is possibly typo.'
    assert_includes result, 'Did you mean: progressive'
  end

  def test_transposed_typo_is_detected
    typo = @checker.find_typo('recieve')

    refute_nil typo
    assert_equal 'receive', typo.suggestions.first
  end

  def test_common_typos_rank_expected_word_in_top_three
    fixtures = File.readlines(File.expand_path('fixtures/common_typos.tsv', __dir__), chomp: true)

    fixtures.each do |line|
      typo, expected = line.split("\t")
      suggestions = @checker.find_typo(typo)&.suggestions || []

      assert_includes suggestions.first(3), expected, "#{typo} should suggest #{expected} in top 3"
    end
  end
end
