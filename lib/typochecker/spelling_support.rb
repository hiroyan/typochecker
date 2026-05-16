# frozen_string_literal: true

module Typochecker
  # 英単語の辞書構築や語形変化を扱う共有ヘルパー。
  module SpellingSupport
    ALPHABETS = ('a'..'z').to_a.freeze
    VOWELS = 'aiueo'
    CONSONANTS = ALPHABETS.reject { |alphabet| VOWELS.include?(alphabet) }.join.freeze

    PAST_TENSE_RULES = [
      {
        regex: /[#{CONSONANTS}][#{VOWELS}][#{CONSONANTS}]$/,
        convert: ->(word) { "#{word}#{word[-1]}ed" }
      },
      {
        regex: /[#{CONSONANTS}]y$/,
        convert: ->(word) { "#{word.chop}ied" }
      },
      {
        regex: /e$/,
        convert: ->(word) { "#{word}d" }
      },
      {
        regex: //,
        convert: ->(word) { "#{word}ed" }
      }
    ].freeze

    PRESENT_PROGRESSIVE_TENSE_RULES = [
      {
        regex: /ie$/,
        convert: ->(word) { "#{word.chop.chop}ying" }
      },
      {
        regex: /[#{CONSONANTS}][#{VOWELS}][#{CONSONANTS}]$/,
        convert: ->(word) { "#{word}#{word[-1]}ing" }
      },
      {
        regex: /e$/,
        convert: ->(word) { "#{word.chop}ing" }
      },
      {
        regex: //,
        convert: ->(word) { "#{word}ing" }
      }
    ].freeze

    PLURAL_FORM_RULES = [
      {
        regex: /(f|fe)$/,
        convert: ->(word) { "#{word.sub(/(f|fe)$/, '')}ves" }
      },
      {
        regex: /[#{CONSONANTS}]y$/,
        convert: ->(word) { "#{word.chop}ies" }
      },
      {
        regex: /(s|sh|ch|x)$/,
        convert: ->(word) { "#{word}es" }
      },
      {
        regex: //,
        convert: ->(word) { "#{word}s" }
      }
    ].freeze

    module_function

    def word_variations(word)
      [
        convert_word(PAST_TENSE_RULES, word),
        convert_word(PRESENT_PROGRESSIVE_TENSE_RULES, word),
        convert_word(PLURAL_FORM_RULES, word)
      ]
    end

    BASE_WORD = 0
    GENERATED_VARIATION = 1

    def make_dictionary(dictionary_file, keyword_file = nil)
      {}.tap do |dictionary|
        load_word_list_file(dictionary, dictionary_file)
        load_word_list_file(dictionary, keyword_file) if keyword_file
      end
    end

    def parse_words(line)
      words = line.scan(/[a-zA-Z][a-z]+/).map(&:downcase)
      words += line.scan(/\W([A-Z]+)\W/).flatten.map(&:downcase)
      words.uniq
    end

    def convert_word(rules, word)
      rules.find { |rule| word.match?(rule[:regex]) }[:convert].call(word)
    end

    def load_word_list_file(dictionary, word_list_file)
      File.readlines(word_list_file).each do |word|
        normalized_word = word.strip.downcase
        dictionary[normalized_word] = BASE_WORD
        word_variations(normalized_word).each do |variation|
          dictionary[variation] ||= GENERATED_VARIATION
        end
      end
    end
  end
end
