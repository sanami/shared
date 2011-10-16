
UrlData = Struct.new(:url, :pos, :length)

##
# Если делать так, то не работает т.к. currentBlock.setUserData принимает только Qt::TextBlockUserData
#
=begin
class BlockUrlData < Qt::TextBlockUserData
	#p methods
	#attr_accessor :urls

	def initialize
		@urls = []
	end

	def push(url)
		@urls ||= []
		@urls << url
	end

	def each
		@urls.each { |url| yield url }
	end
end
=end

##
# Добавление в класс нового атрибута
Qt::TextBlockUserData.class_eval 'attr_accessor :urls'

##
# Подсветка + сбор информации о ссылках
class HighlighterBase < Qt::SyntaxHighlighter
	Rule = Struct.new(:pattern, :format)

	def initialize(doc, type, args = {})
		super doc
		@find_urls = args[:find_urls] || false

		@rules = []
		@rules_merge = []

		@rx_url = Qt::RegExp.new '(http.*)(?=[\[\]])'
		@rx_url.setMinimal true

		method("init_#{type.to_s}").call
	end

protected
	##
	# Добавить полное форматирование, последующие аргументы - список регекспов
	def add(format, *patterns)
		patterns.each do |pattern|
			rx = Qt::RegExp.new(pattern)
			rx.setMinimal true
			rx.setCaseSensitivity Qt::CaseInsensitive
			@rules << Rule.new(rx, format)
		end
	end

	##
	# Добавить частичное форматирование, последующие аргументы - список регекспов
	def add_merge(format, *patterns)
		patterns.each do |pattern|
			rx = Qt::RegExp.new(pattern)
			rx.setMinimal true
			rx.setCaseSensitivity Qt::CaseInsensitive
			@rules_merge << Rule.new(rx, format)
		end
	end

	##
	# Вызывается Qt для каждого блока текста
	def highlightBlock(text)
		if @find_urls
			dat = currentBlockUserData
			unless dat
				dat = Qt::TextBlockUserData.new
				currentBlock.setUserData dat
			end

			index = @rx_url.indexIn(text, 0)
			while (index >= 0) do
				url = @rx_url.cap(1).clone
				length = @rx_url.matchedLength
				dat.urls ||= []
				dat.urls << UrlData.new(url, index, length)

				index = @rx_url.indexIn(text, index + length)
			end
		end

		@rules.each do |rule|
			index = rule.pattern.indexIn(text, 0)
			while (index >= 0) do
				length = rule.pattern.matchedLength
				#puts "highlightBlock #{index}, #{length}"
				setFormat(index, length, rule.format)
				index = rule.pattern.indexIn(text, index + length)
			end
		end

		@rules_merge.each do |rule|
			index = rule.pattern.indexIn(text, 0)
			while (index >= 0) do
				length = rule.pattern.matchedLength
				#puts "highlightBlock #{index}, #{length}"
				#setFormat(index, length, rule.format)

				# Фрагменты текста с одинаковым форматированием
				# тоже самое что QTextFragment в QTextBlock
				last_fmt = nil
				text_fragments = []
				(index...index+length).each do |i|
					fmt = format(i)
					if fmt != last_fmt
						#puts "#{i} #{fmt}"
						last_fmt = fmt
						text_fragments << i
					end
				end
				# Если в массиве только первый индекс, то значит текст только с одним форматом
				text_fragments << (index+length) if text_fragments.size == 1 # Вставить конец

				text_fragments.each_cons(2) do |i1, i2|
					#p a1, a2
					fmt = format i1
					rule.format.each do |action|
						eval "fmt.#{action}"
					end
					setFormat(i1, i2-i1, fmt)
				end

				index = rule.pattern.indexIn(text, index + length)
			end
		end
	end
end
