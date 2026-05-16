# frozen_string_literal: true

module Typochecker
  # 候補語を、入力語に対して自然に見える順へ並べる。
  class SuggestionRanker
    def initialize(dictionary)
      @dictionary = dictionary
    end

    def rank(word, suggestions)
      suggestions.sort_by { |suggestion| score(word, suggestion) }
    end

    private

    def score(word, suggestion)
      [
        damerau_levenshtein_distance(word, suggestion),
        transposition_penalty(word, suggestion),
        dictionary_penalty(suggestion),
        first_letter_penalty(word, suggestion),
        repeated_letter_penalty(word, suggestion),
        -bigram_similarity(word, suggestion),
        (word.length - suggestion.length).abs,
        suggestion
      ]
    end

    def dictionary_penalty(suggestion)
      @dictionary.fetch(suggestion)
    end

    def transposition_penalty(word, suggestion)
      adjacent_transposition?(word, suggestion) ? 0 : 1
    end

    def first_letter_penalty(word, suggestion)
      word[0] == suggestion[0] ? 0 : 1
    end

    def repeated_letter_penalty(word, suggestion)
      missing_repeated_letter?(word, suggestion) ? 0 : 1
    end

    def missing_repeated_letter?(word, suggestion)
      suggestion.chars.each_cons(2).any? do |left, right|
        left == right && !word.include?(left * 2)
      end
    end

    def adjacent_transposition?(word, suggestion)
      return false unless word.length == suggestion.length

      differences = word.each_char.with_index.select { |character, index| character != suggestion[index] }
      return false unless differences.length == 2

      first_index = differences[0][1]
      second_index = differences[1][1]
      return false unless second_index == first_index + 1

      word[first_index] == suggestion[second_index] &&
        word[second_index] == suggestion[first_index]
    end

    def bigram_similarity(left, right)
      left_bigrams = bigrams(left)
      right_bigrams = bigrams(right)
      return 0.0 if left_bigrams.empty? || right_bigrams.empty?

      overlap = left_bigrams.count { |bigram| right_bigrams.include?(bigram) }
      (2.0 * overlap) / (left_bigrams.length + right_bigrams.length)
    end

    def bigrams(word)
      word.chars.each_cons(2).map(&:join)
    end

    # 隣接転置を 1 編集として扱う Optimal String Alignment 距離。
    def damerau_levenshtein_distance(left, right)
      rows = left.length + 1
      columns = right.length + 1
      matrix = Array.new(rows) { Array.new(columns, 0) }

      rows.times { |row| matrix[row][0] = row }
      columns.times { |column| matrix[0][column] = column }

      (1...rows).each do |row|
        (1...columns).each do |column|
          cost = left[row - 1] == right[column - 1] ? 0 : 1
          matrix[row][column] = [
            matrix[row - 1][column] + 1,
            matrix[row][column - 1] + 1,
            matrix[row - 1][column - 1] + cost
          ].min

          next unless row > 1 && column > 1
          next unless left[row - 1] == right[column - 2] && left[row - 2] == right[column - 1]

          matrix[row][column] = [matrix[row][column], matrix[row - 2][column - 2] + 1].min
        end
      end

      matrix[-1][-1]
    end
  end
end
