require 'minitest/spec'
require 'minitest/autorun'

require_relative '../lib/transync/transync_config'
require_relative '../lib/transync/gdoc_trans/gdoc_trans_reader'
require_relative '../lib/transync/gdoc_trans/gdoc_trans_writer'
require_relative '../lib/transync/sync/sync_util'
require_relative '../lib/transync/sync/translation_sync'
require_relative '../lib/transync/xliff_trans/xliff_trans_reader'

describe 'x2g' do
  before do
    @file      = 'test'
    @path      = 'test/fixtures'
    @language  = 'en'
    @languages = %w(en de)
    SyncUtil.create_logger('x2g_test')
  end

  it 'test if xliff files are valid' do
    xliff_files = XliffTransReader.new(@path, 'test', @languages)
    xliff_files.valid?.must_equal true

    xliff_files = XliffTransReader.new(@path, 'validators', @languages)
    xliff_files.valid?.must_equal false, 'validators translations should not be valid, because we do not have all keys in german file.'
  end

  it 'x2g sync should build correct new hash before writing it back to google doc' do
    trans_sync = TranslationSync.new(@path, 'x2g', @file)
    trans_hash = trans_sync.sync(@language, 'x2g')

    trans_hash[:file].must_equal @file
    trans_hash[:language].must_equal @language
    trans_hash[:translations].keys.size.must_equal 4

    trans_hash[:translations]['title'].must_equal 'Title'
    trans_hash[:translations]['round'].must_equal 'Round'
    trans_hash[:translations]['end_test'].must_equal 'End test'
    trans_hash[:translations]['end_test_2'].must_equal 'End test 2'

    gdoc_trans_reader = GdocTransReader.new(@file)
    gdoc_trans_writer = GdocTransWriter.new(gdoc_trans_reader.worksheet)
    gdoc_trans_writer.get_language_column_index('en').must_equal 2
    gdoc_trans_writer.get_language_column_index('de').must_equal 3
  end
end
