require 'test/unit'
require '../qt/misc.rb'

class TC_QtTest < Test::Unit::TestCase
	def setup
		@app = Qt::Application.new(ARGV)
		Qt::init_codec 'utf-8'
	end

	def teardown
	end

	def test_save_widget
		#Qt.debug_level = Qt::DebugLevel::High

		splitter = Qt::Splitter.new
		splitter.setObjectName 'www_splitter'

		w = Qt::ListWidget.new
		w.setObjectName 'www1'
		w.setAlternatingRowColors true
		Qt::set_high_contrast_palette w
		10.times { |i| w.addItem i.to_s }
		splitter.addWidget w

		w2 = Qt::ListWidget.new
		w2.setObjectName 'www2'
		w2.setAlternatingRowColors true
		Qt::set_high_contrast_palette w2
		10.times { |i| w2.addItem i.to_s }
		splitter.addWidget w2

		form = Qt::MainWindow.new
		form.setCentralWidget splitter
		form.show

		Qt::save_widget form, [splitter]

		GC.start
		@app.exec
	end
end

