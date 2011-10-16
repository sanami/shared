#таблица соответствия русских строчных/прописных букв
$rx_unicode_table = {}
$rx_unicode_table_lower = {
	'ё' => 'Ё',
	'й' => 'Й',
	'ц' => 'Ц',
	'у' => 'У',
	'к' => 'К',
	'е' => 'Е',
	'н' => 'Н',
	'г' => 'Г',
	'ш' => 'Ш',
	'щ' => 'Щ',
	'з' => 'З',
	'х' => 'Х',
	'ъ' => 'Ъ',
	'ф' => 'Ф',
	'ы' => 'Ы',
	'в' => 'В',
	'а' => 'А',
	'п' => 'П',
	'р' => 'Р',
	'о' => 'О',
	'л' => 'Л',
	'д' => 'Д',
	'ж' => 'Ж',
	'э' => 'Э',
	'я' => 'Я',
	'ч' => 'Ч',
	'с' => 'С',
	'м' => 'М',
	'и' => 'И',
	'т' => 'Т',
	'ь' => 'Ь',
	'б' => 'Б',
	'ю' => 'Ю'
}

$rx_unicode_table_upper = $rx_unicode_table_lower.invert
#$rx_unicode_table_lower.each { |k,v| $rx_unicode_table_upper[v] = k }
$rx_unicode_table.merge! $rx_unicode_table_lower
$rx_unicode_table.merge! $rx_unicode_table_upper

def inspect_rx_unicode
	puts "$rx_unicode_table_lower #{$rx_unicode_table_lower.inspect} entries"
	puts "$rx_unicode_table_upper #{$rx_unicode_table_upper.inspect} entries"
	puts "$rx_unicode_table #{$rx_unicode_table.inspect} entries"
end

#case insensitive regexp
#NOTE не использовать с [а-Я]
def create_rx(str, opt = Regexp::IGNORECASE)
	fixed_str = ''
	brackets = [] #список вложенных [..]

	prev_c = ''
	str.each_char do |c|
		if prev_c != "\\"
			if c == '['
				brackets.push(c)
			elsif (c == ']')
				brackets.pop
			end
		end

		if $rx_unicode_table.has_key?(c)
			if brackets.empty?
				fixed_str << "[#{c}#{$rx_unicode_table[c]}]"  #уже в
			else
				fixed_str << "#{c}#{$rx_unicode_table[c]}"    #без []
			end
		else
			fixed_str << c
		end
		prev_c = c
	end
	
	#puts "create_rx #{fixed_str}"
	Regexp.new(fixed_str, opt)
rescue Exception => ex
	save_error ex
	Regexp.new(str, opt)
end

def to_table_case(str, table)
	lower_str = ''
	str.each_char do |c|
		lower_c = table.index(c)
		lower_str << (lower_c ? lower_c : c)
	end
	lower_str
end

def to_downcase(str)
	to_table_case(str, $rx_unicode_table_lower)
end

def to_upcase(str)
	to_table_case(str, $rx_unicode_table_upper)
end
