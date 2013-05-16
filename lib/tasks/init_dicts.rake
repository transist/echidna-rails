namespace :db do
  desc 'Initialize dicts data from dicts files'
  task init_dicts: :environment do
    Dir[Rails.root.join('lib/dicts/parser/*.rb')].each { |file| require_relative file }

    if ENV['FORCE_FLUSH']
      Homonym.flush
      Stopword.flush
      Synonym.flush
      Word.flush
      Hypernym.flush
    end
    # Dicts::Parser::ModernChineseDictParser.new.parse
    puts 'Parsing stopwords...'
    Dicts::Parser::StopwordsParser.new.parse
    puts 'Parsing synonyms...'
    Dicts::Parser::SynonymsDictParser.new.parse
    puts 'Parsing words...'
    Dicts::Parser::WordsDictParser.new.parse
    puts 'Parsing Chinese Pinyin...'
    Dicts::Parser::ChinesePinyinParser.new.parse
    Dicts::Parser::HypernymsDictParser.new.parse
    puts 'Dicts parsed successfuly'
  end
end
