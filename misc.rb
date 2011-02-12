require 'rubygems'
#TODO спец обработку только для Ruby 1.8, в 1.9 использовать стандартную поддержку юникода
$KCODE = 'UTF-8'
require 'jcode'
require 'iconv'
#require 'charguess' #библиотека не установлена    from = CharGuess::guess str
require 'pp'
require 'yaml'
require 'logger'
require 'fileutils'

require File.dirname(__FILE__) + '/rx_unicode.rb'
require File.dirname(__FILE__) + '/ya2yaml.rb' # YAML в utf-8

$console_codec = 'utf-8'  # Кодировка в которой консоль правильно отображает текст
$string_codec = 'utf-8'   # Кодировка строк в программе
$os_codec = 'utf-8'       # Кодировка операционной системы ('windows-1251')

#Лог ошибок TODO перейти на log4r
$error_logger = nil

##
# Определение кодировок строк и консоли
def init_codec(console_codec = 'utf-8', string_codec = 'utf-8', os_codec = 'utf-8')
	$console_codec = console_codec
	$string_codec = string_codec
  $os_codec = os_codec
end

##
# Путь к файлу лога ошибок, если путь не установлен выбрать по умолчанию
def init_logger(log_path = 'log/error.log')
	log_dir = File.dirname(log_path)
	FileUtils.mkpath log_dir

	$error_logger = Logger.new(log_path)
end

##
# Переопределение стандартных методов печати для поддержки кодировок
alias original_print print
def print(*args)
	original_print Iconv.conv($console_codec, $string_codec, args.join)
rescue
	original_print(*args)
end

alias original_puts puts
def puts(*objs)
	objs.each { |obj| original_puts Iconv.conv($console_codec, $string_codec, obj) }
rescue #=> ex
	#original_puts ex
	original_puts(*objs)
end

alias original_p p
def p(*objs)
	objs.each { |obj| puts(obj.inspect) }
rescue
	original_p(*objs)
end

alias original_y y
def y(*objs)
	#objs.each { |obj| puts(obj.to_yaml) }
	objs.each { |obj| puts(obj.ya2yaml) }
rescue
	original_y(*objs)
end

##
# Очистить текст (удалить лишние пробелы)
def clean_text(str)
	#не пробел ' ' код 160
	str.gsub(/[\s ]+/, ' ').strip
end

##
# Сменить кодировку с юникода на стандартную
def to_win(str, from = $string_codec)
	Iconv.conv('windows-1251', from, str)
rescue
	#TODO В режиме отладки не игнорировать такие ошибки
	str
end

##
# Сменить кодировку с юникода на dos кодировку, используется для имен файлов в Zip
def to_dos(str, from = $string_codec)
	Iconv.conv('ibm866', from, str)
rescue
	str
end

##
# Сменить кодировку со стандартной на юникод
def to_utf(str, from = $os_codec)
	Iconv.conv('utf-8', from, str)
rescue
	str
end


##
# Записать подробную ошибку Exception в errors.log
def save_error(ex)
	error_str = ex.inspect  + "\n" + ex.backtrace.join("\n")
	puts error_str

	if $error_logger
		$error_logger.error to_utf(error_str, $os_codec)
	end

	nil # Вернуть nil
end


def require_local(file_name, param = __FILE__)
	pp param
#	file_dir = File.dirname(param)
#	require "#{file_dir}/#{file_name}"
end

def save_log(file_name, str, convert_to_win = true)
	open(file_name, 'w') do |f|
		f << (convert_to_win ? to_win(str) : str)
	end
end

def save_file(file_name, data)
	open(file_name, 'wb') do |f|
		f.write data
	end
end
