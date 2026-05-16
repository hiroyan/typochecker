# frozen_string_literal: true

module Typochecker
  # 入力中の typo 候補を検出する本体。
  class TypoChecker
    MIN_WORD_LEN = 5
    LEVENSHTEIN_DISTANCE = 1

    TypoInfo = Struct.new(:word, :suggestions)

    def initialize(min_word_len: MIN_WORD_LEN,
                   levenshtein_distance: LEVENSHTEIN_DISTANCE,
                   dictionary_file: Typochecker.default_dictionary_file,
                   keyword_file: nil)
      @min_word_len = min_word_len
      @levenshtein_distance = levenshtein_distance
      @dictionary = SpellingSupport.make_dictionary(dictionary_file, keyword_file)
      @candidate_generator = CandidateGenerator.new(min_word_len: min_word_len)
      @suggestion_ranker = SuggestionRanker.new(@dictionary)
      @typo_cache = {}
    end

    def check_file(file_name)
      File.readlines(file_name).each_with_index.each_with_object(+'') do |(line, line_count), result|
        check_line(line).each do |typo|
          result << "#{line_count}: #{typo.word} is possibly typo. "
          result << "Did you mean: #{typo.suggestions.join(',')}\n"
        end
      end
    end

    def check_line(line)
      SpellingSupport.parse_words(line)
                     .reject { |word| word.length < @min_word_len }
                     .map { |word| find_typo(word) }
                     .compact
    end

    def find_typo(word)
      return nil if @dictionary.key?(word)
      return TypoInfo.new(word, @typo_cache[word]) if @typo_cache.key?(word)

      suggestions = candidate_words(word).select { |suggestion| @dictionary.key?(suggestion) }.uniq
      return nil if suggestions.empty?

      suggestions = @suggestion_ranker.rank(word, suggestions)
      @typo_cache[word] = suggestions
      TypoInfo.new(word, suggestions)
    end

    private

    def candidate_words(word)
      @candidate_generator.generate(word, distance: @levenshtein_distance)
    end
  end
end
