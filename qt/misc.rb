# encoding: utf-8
require 'Qt4'
require File.dirname(__FILE__) + '/generate.rb'

module Qt

##
# Инициализация кодека используемого Qt
def self.init_codec(codec_str = 'utf-8')
	codec = Qt::TextCodec::codecForName(codec_str)
	Qt::TextCodec::setCodecForCStrings(codec)
	Qt::TextCodec::setCodecForLocale(codec)
	Qt::TextCodec::setCodecForTr(codec)
end

##
# Убрать лишние spacing & margins
def self.optimize_layouts(widget)
	all_layout = widget.findChildren Qt::GridLayout
	all_layout.each do |obj|
		obj.setSpacing(3)
		#obj.setContentsMargins(3,3,3,6)
		obj.setMargin(0)
	end
end

##
# Оптимизация цветов
def self.set_high_contrast_palette(widget)
	pal = widget.palette
	# Подсветка четных строк
	pal.setBrush(Qt::Palette::AlternateBase, Qt::Brush.new(Qt::Color.new(0xE0, 0xE0, 0xE0)))

	# Оставлять строку выделенной, если виджет не в фокусе, не работает
	b = Qt::Brush.new(Qt::Color.new('#ff0'))
	b2 = Qt::Brush.new(Qt::Color.new('#f00'))
	pal.setBrush(Qt::Palette::Inactive, Qt::Palette::Highlight, b)
	pal.setBrush(Qt::Palette::Inactive, Qt::Palette::HighlightedText, b2)
#	pal.setBrush(Qt::Palette::Inactive, Qt::Palette::Highlight, pal.brush(Qt::Palette::Active, Qt::Palette::Highlight))
#	pal.setBrush(Qt::Palette::Inactive, Qt::Palette::HighlightedText, pal.brush(Qt::Palette::Active, Qt::Palette::HighlightedText))
	widget.palette = pal

	#TODO Правка цветов
#	p = Qt::Application::palette
#	p.setColor(Qt::Palette::Inactive, Qt::Palette::Highlight, Qt::Color.new(Qt::red))
#	p.setColor(Qt::Palette::Inactive, Qt::Palette::Highlight)
	
#	Qt::Application::setPalette p
end

def self.save_widget(parent, children = [])
	children = parent.children if children.empty?

	children.each do |w|
		puts w.objectName
	end
end

end
