module HighlighterBbCode
	def init_bbcode
		# ������ [], ���� ������
		fmt = Qt::TextCharFormat.new
		fmt.setBackground(Qt::Brush.new(Qt::Color.new("#FF0000")))
		add(fmt, '[\[\]]')


		# ��� [url], [urlnf]
		fmt = Qt::TextCharFormat.new
		fmt.setFontUnderline true
		add(fmt, '\[url=?.*\].*\[/url\]', '\[urlnf=?.*\].*\[/urlnf\]')

		# ��� [b]
		fmt = Qt::TextCharFormat.new
		fmt.setFontWeight 75
		add(fmt, '\[b\].*\[/b\]')  # '\[b\].*(?=\[/b\])'

		# ��� [i]
		fmt = Qt::TextCharFormat.new
		fmt.setFontItalic true
		add(fmt, '\[i\].*\[/i\]')

		# ���� [url][i]
		#fmt = Qt::TextCharFormat.new
		#fmt.setFontUnderline true
		#fmt.setFontItalic true
		#add(fmt, '\[url=?.*\]\[i\].*\[/i\]\[/url\]')

		# ��� [s]
		fmt = Qt::TextCharFormat.new
		fmt.setFontStrikeOut true
		add(fmt, '\[s\].*\[/s\]')

		# ��� [u]
		fmt = Qt::TextCharFormat.new
		fmt.setFontUnderline true
		add(fmt, '\[u\].*\[/u\]')

		# ��� ���� � ������� [...] � [/...]
		fmt = Qt::TextCharFormat.new
		fmt.setBackground(Qt::Brush.new(Qt::Color.new("#FFA4B9")))
		add(fmt, '\[.*\]');

		# URL http://www.cinematheque.ru/attach/5694/r
		fmt = Qt::TextCharFormat.new
		fmt.setBackground(Qt::Brush.new(Qt::Color.new("#14C1EB")))
		fmt.setFontUnderline true
		add(fmt, 'http.*(?=[\[\]])')

		# ����� � ��������
		fmt = Qt::TextCharFormat.new
		fmt.setBackground(Qt::Brush.new(Qt::Color.new("#B6F449")))
		add(fmt, '[�<"].+[�>"]')
	end
end
