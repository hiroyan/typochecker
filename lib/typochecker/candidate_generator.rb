# frozen_string_literal: true

module Typochecker
  # 指定距離内の候補語を高速に列挙する。
  class CandidateGenerator
    def initialize(min_word_len:)
      @min_word_len = min_word_len
    end

    def generate(word, distance:)
      words = one_edit_words(word)
      return words if distance <= 1

      words.flat_map { |candidate| generate(candidate, distance: distance - 1) }.uniq
    end

    private

    def one_edit_words(word)
      words = word.length <= @min_word_len ? [] : deletes(word)
      words += creates(word)
      words += modifies(word)
      words += transposes(word)
      words.uniq
    end

    def deletes(word)
      (0...word.length).map do |index|
        word.dup.tap { |candidate| candidate.slice!(index) }
      end
    end

    def creates(word)
      SpellingSupport::ALPHABETS.flat_map do |alphabet|
        (0..word.length).map do |index|
          word.dup.tap { |candidate| candidate.insert(index, alphabet) }
        end
      end
    end

    def modifies(word)
      SpellingSupport::ALPHABETS.flat_map do |alphabet|
        (0...word.length).map do |index|
          word.dup.tap { |candidate| candidate[index] = alphabet }
        end
      end
    end

    def transposes(word)
      (0...(word.length - 1)).map do |index|
        word.dup.tap do |candidate|
          candidate[index], candidate[index + 1] = candidate[index + 1], candidate[index]
        end
      end
    end
  end
end
