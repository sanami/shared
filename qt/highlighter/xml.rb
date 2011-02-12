module HighlighterXml
	def init_xml
		#���� <xml
		fmt = Qt::TextCharFormat.new
		fmt.setForeground(Qt::Brush.new(Qt::Color.new(0, 0, 0x99)))
		add(fmt, "<.+>");

		#������ "��������"
		fmt = Qt::TextCharFormat.new
		fmt.setForeground(Qt::Brush.new(Qt::darkGreen))
		add(fmt, "\"[^\"]*\"");

		#XML entity   &amp;
		fmt = Qt::TextCharFormat.new
		fmt.setForeground(Qt::Brush.new(Qt::black))
		#fmt.setFontWeight(Qt::Font::Bold);
		add(fmt, "&.+;");
	end
end
