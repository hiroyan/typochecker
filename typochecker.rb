# Utility modules for spelling of English word
module SpellingSupport
  # list up word variations. past tense, present progressive tense
  # and plural form
  def self.word_variations(word)
    variations = []
    variations << convert_word(PAST_TENSE_RULES, word)
    variations << convert_word(PRESENT_PROGRESSIVE_TENSE_RULES, word)
    variations << convert_word(PLURAL_FORM_RULES, word)
    variations
  end

  # make dictionary of words from words list and keywords list
  def self.make_dictionary(dictionary_file, keyword_file)
    dict = {}
    load_word_list_file(dict, dictionary_file)
    load_word_list_file(dict, keyword_file) if keyword_file
    dict
  end

  # find alphabets in line
  # and split camel case string into words
  def self.parse_words(line)
    words = line.scan(/[a-zA-Z][a-z]+/).map(&:downcase)
    words += line.scan(/\W([A-Z]+)\W/).flatten.map(&:downcase)
    words.uniq
  end

  # list of alphabets
  ALPHABETS = ('a'..'z').to_a

  # list of vowels
  VOWELS = 'aiueo'

  # list of consonants
  CONSONANTS = ALPHABETS.reject { |a| VOWELS.index(a) }.join('')

  # conversion rules for past tense of verb
  # examples:
  # enter -> entered
  # study -> studied
  # chop -> chopped
  # like -> liked
  # other -> append ed
  PAST_TENSE_RULES = [
    # {
    #   regex: /er$/,
    #   convert: -> (word) { "#{word}ed" }
    # },
    {
      regex: /[#{CONSONANTS}][#{VOWELS}][#{CONSONANTS}]$/,
      convert: -> (word) { "#{word}#{word[-1]}ed" } },
    {
      regex: /[#{CONSONANTS}]y$/,
      convert: -> (word) { "#{word.chop}ied" }
    },
    {
      regex: /e$/,
      convert: -> (word) { "#{word}d" }
    },
    {
      regex: //,
      convert: -> (word) { "#{word}ed" }
    }
  ]

  # conversion rules for present progressive tense of verb
  # examples:
  # lie -> lying
  # chop -> chopping
  # love -> loving
  # other -> append ing
  PRESENT_PROGRESSIVE_TENSE_RULES = [
    {
      regex: /ie$/,
      convert: -> (word) { "#{word.chop.chop}ying" }
    },
    {
      regex: /[#{CONSONANTS}][#{VOWELS}][#{CONSONANTS}]$/,
      convert: -> (word) { "#{word}#{word[-1]}ing" }
    },
    {
      regex: /e$/,
      convert: -> (word) { "#{word.chop}ing" }
    },
    {
      regex: //,
      convert: -> (word) { "#{word}ing" }
    }
  ]

  # conversion rules for plural form of noun
  # examples:
  # knife -> knives
  # baby -> babies
  # brush -> brushes
  # other -> append s
  PLURAL_FORM_RULES = [
    {
      regex: /(f|fe)$/,
      convert: -> (word) { "#{word.sub(/(f|fe)$/, '')}ves" }
    },
    {
      regex: /[#{CONSONANTS}]y$/,
      convert: -> (word) { "#{word.chop}ies" }
    },
    {
      regex: /(s|sh|ch|x)$/,
      convert: -> (word) { "#{word}es" }
    },
    {
      regex: //,
      convert: -> (word) { "#{word}s" }
    }
  ]

  # default words list path (on linux or osx)
  DEFALT_DICTIONARY_FILE = '/usr/share/dict/words'

  # convert word with a rule
  def convert_word(rules, word)
    rules.find { |rule| word =~ rule[:regex] }[:convert].call(word)
  end

  # load file of word list and store each words in dictionary (Hash)
  def load_word_list_file(dict, word_list_file)
    File.readlines(word_list_file).each do |word|
      word = word.strip.downcase
      dict[word] = true
      SpellingSupport.word_variations(word).each do |variation|
        dict[variation] = true
      end
    end
  end

  # find typo in line/file and suggest correct words
  class TypoChecker
    # minimum length of word for typo checking
    MIN_WORD_LEN = 5

    # default levenshtein distance
    LEVENSHTEIN_DISTANCE = 1

    # correct word list
    @dictionary = nil

    TypoInfo = Struct.new(:word, :suggestions)

    def initialize(min_word_len: MIN_WORD_LEN,
                   levenshtein_distance: LEVENSHTEIN_DISTANCE,
                   dictionary_file: DEFALT_DICTIONARY_FILE, keyword_file: nil)
      @min_word_len = min_word_len
      @levenshtein_distance = levenshtein_distance
      @keyword_file = keyword_file
      @dictionary =
        SpellingSupport.make_dictionary(dictionary_file, keyword_file)
      @typo_cache = {}
    end

    # return typo informations in each lines
    def check_file(file_name)
      ret = ''
      File.readlines(file_name).each_with_index do |line, line_count|
        typos = check_line(line)
        next if typos.length == 0
        typos.each do |typo|
          ret += "#{line_count}: #{typo.word} is possibly typo. "
          ret += "Did you mean: #{typo.suggestions.join(',')}\n"
        end
      end
      ret
    end

    # return list of typo information
    def check_line(line)
      words = SpellingSupport.parse_words(line).reject do |word|
        word.length < @min_word_len
      end
      typos = []
      words.each do |word|
        typo = find_typo(word)
        next unless typo
        typos << typo
      end
      typos
    end

    # find out whether input word is typo
    # return correct word suggestions if input word is possibly typo
    # or return nil
    def find_typo(word)
      return nil if @dictionary.key?(word)
      return TypoInfo.new(word, @typo_cache[word]) if @typo_cache.key?(word)

      suggestions = levenshtein_words(word).select do |suggestion|
        @dictionary.key?(suggestion)
      end
      return nil if suggestions.length == 0
      suggestions.uniq!

      # store typo information in cache
      @typo_cache[word] = suggestions
      TypoInfo.new(word, suggestions)
    end

    private

    # list up words with 1 or more levenshtein distance from input word
    def levenshtein_words(word, distance = @levenshtein_distance)
      words = word.length <= @min_word_len ? [] : levenshtein_delete(word)
      words += levenshtein_create(word)
      words += levenshtein_modify(word)

      distance -= 1
      return words if distance <= 0
      words = words.map { |w| levenshtein_words(w, distance) }
      words.flatten.uniq
    end

    # list up words with 1 delete levenshtein distance from input
    def levenshtein_delete(word)
      deleted_words = (0..word.length - 1).to_a.map do |i|
        delete = word.dup
        delete.slice!(i)
        delete
      end
      deleted_words.uniq
    end

    # list up words with 1 create levenshtein distance from input
    def levenshtein_create(word)
      created_words = ALPHABETS.map do |a|
        (0..word.length).to_a.map do |i|
          create = word.dup
          create.insert(i, a)
          create
        end
      end
      created_words.flatten.uniq
    end

    # list up words with 1 modify levenshtein distance from input
    def levenshtein_modify(word)
      modified_words = ALPHABETS.map do |a|
        (0..word.length - 1).to_a.map do |i|
          modify = word.dup
          modify[i] = a
          modify
        end
      end
      modified_words.flatten.uniq
    end
  end
end

if $PROGRAM_NAME == __FILE__
  # main. run typochecker as ruby script
  require 'optparse'

  include SpellingSupport

  parser = OptionParser.new
  options = {}
  parser.on('-d', '--dictionary DICT') { |dict| options[:dict] = dict }
  parser.on('-k', '--keyword KEYWORD_FILE') { |key| options[:key] = key }
  parser.parse!(ARGV)

  targetfile = parser.default_argv[0]
  unless targetfile
    u = 'Usage: ruby typochecker.rb (-d dictionary -k keyword) #{targetfile}'
    fail u
  end

  dictionary_file = options[:dict] || SpellingSupport::DEFALT_DICTIONARY_FILE
  keyword_file = options[:key]

  typochecker = TypoChecker.new(dictionary_file: dictionary_file,
                                keyword_file: keyword_file)

  puts typochecker.check_file(targetfile)

  exit 0
end
