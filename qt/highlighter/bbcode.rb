module HighlighterBbCode
	def init_bbcode
		# Скобки [], если ошибка
		fmt = Qt::TextCharFormat.new
		fmt.setBackground(Qt::Brush.new(Qt::Color.new("#FF0000")))
		add(fmt, '[\[\]]')


		# Тэг [url], [urlnf]
		fmt = Qt::TextCharFormat.new
		fmt.setFontUnderline true
		add(fmt, '\[url=?.*\].*\[/url\]', '\[urlnf=?.*\].*\[/urlnf\]')

		# Тэг [b]
		fmt = Qt::TextCharFormat.new
		fmt.setFontWeight 75
		add(fmt, '\[b\].*\[/b\]')  # '\[b\].*(?=\[/b\])'

		# Тэг [i]
		fmt = Qt::TextCharFormat.new
		fmt.setFontItalic true
		add(fmt, '\[i\].*\[/i\]')

		# Тэги [url][i]
		#fmt = Qt::TextCharFormat.new
		#fmt.setFontUnderline true
		#fmt.setFontItalic true
		#add(fmt, '\[url=?.*\]\[i\].*\[/i\]\[/url\]')

		# Тэг [s]
		fmt = Qt::TextCharFormat.new
		fmt.setFontStrikeOut true
		add(fmt, '\[s\].*\[/s\]')

		# Тэг [u]
		fmt = Qt::TextCharFormat.new
		fmt.setFontUnderline true
		add(fmt, '\[u\].*\[/u\]')

		# Все тэги в скобках [...] и [/...]
		fmt = Qt::TextCharFormat.new
		fmt.setBackground(Qt::Brush.new(Qt::Color.new("#FFA4B9")))
		add(fmt, '\[.*\]');

		# URL http://www.cinematheque.ru/attach/5694/r
		fmt = Qt::TextCharFormat.new
		fmt.setBackground(Qt::Brush.new(Qt::Color.new("#14C1EB")))
		fmt.setFontUnderline true
		add(fmt, 'http.*(?=[\[\]])')

		# Текст в кавычках
		fmt = Qt::TextCharFormat.new
		fmt.setBackground(Qt::Brush.new(Qt::Color.new("#B6F449")))
		add(fmt, '[«<"].+[»>"]')
	end
end
