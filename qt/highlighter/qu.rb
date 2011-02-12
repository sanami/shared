module HighlighterQu
	@@types = %w[shortanswer truefalse matching essay description cloze multichoice numerical order].map {|w| "\\b#{w}\\b"}

	def init_qu
		#формула между $$
		fmt = Qt::TextCharFormat.new
		#fmt.setForeground(Qt::Brush.new(Qt::darkGreen))
		fmt.setForeground(Qt::Brush.new(Qt::red))
		add(fmt, '\$\$.+\$\$');

		fmt = Qt::TextCharFormat.new
		#fmt.setForeground(Qt::Brush.new(Qt::darkGreen))
		fmt.setForeground(Qt::Brush.new(Qt::darkRed))
		add(fmt, '\{.*\}');

		fmt = Qt::TextCharFormat.new
		fmt.setBackground(Qt::Brush.new(Qt::magenta))
		fmt.setFontWeight(Qt::Font::Bold)
		#fmt.setForeground(Qt::Brush.new(Qt::blue))
		add(fmt, *@@types);

		fmt = Qt::TextCharFormat.new
		fmt.setBackground(Qt::Brush.new(Qt::yellow))
		fmt.setFontWeight(Qt::Font::Bold)
		#fmt.setForeground(Qt::Brush.new(Qt::darkRed))
		add(fmt, '^\w+:');

		fmt = Qt::TextCharFormat.new
		fmt.setBackground(Qt::Brush.new(Qt::green))
		fmt.setFontWeight(Qt::Font::Bold)
		#fmt.setForeground(Qt::Brush.new(Qt::darkRed))
		add(fmt, '^\s*[\da-z]+\s*[\.\)]');

		fmt = Qt::TextCharFormat.new
		fmt.setBackground(Qt::Brush.new(Qt::blue))
		fmt.setFontWeight(Qt::Font::Bold)
		add(fmt, '^\s*\+\s*\w[\.\)]');

		fmt = Qt::TextCharFormat.new
		fmt.setBackground(Qt::Brush.new(Qt::red))
		#fmt.setFontWeight(Qt::Font::Bold)
		#fmt.setForeground(Qt::Brush.new(Qt::darkRed))
		add(fmt, '^\s*(image|img).*:');

	end
end
