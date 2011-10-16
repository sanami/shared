require 'rubygems'
require 'mechanize'
require 'net/http'
require 'logger'
require 'zip/zip'
require File.dirname(__FILE__) + '/misc.rb'

# Работа с сетью, запрос на страницу, проверка на наличие в каталоге cache, если нет, то запрос
# Если :is_temporal, то кешировать на время запуска программы - отдельный каталог, очищать на старте
class Cache
	@@global_initialized = false
	@@cache_path = './cache/'
	@@temp_path = './cache/_temp/'

	# Время устаревания временных файлов
	@@temp_expire = 60*60*12 # 12 часов
	#@@temp_expire = 60*60*3 # 3 часа

	def initialize()
		Cache.init_global unless @@global_initialized

		@agent = Mechanize.new { |a| a.log = Logger.new("#{@@cache_path}mechanize.log") }
		@agent.user_agent_alias = 'Windows Mozilla'

		@headers = {}
		@headers['Accept-Language'] = 'ru-ru;q=1.0'
		#@headers['Accept'] = '*/*'
		#@headers['user-agent'] = 'Mozilla/5.0'
		@headers['connection'] = 'keep-alive'
		#@headers['Accept-Encoding'] = 'deflate'
		#@headers['Accept-Charset'] = 'windows-1251;q=1.0'
		@headers['Accept-Charset'] = 'utf-8;q=1.0'
		@headers['keep-alive'] = '30'

		@is_logged = false

		#расширения файлов которые можно запаковать
		@packable_files = %w[.doc .xls]
	end

	##
	# Глобальная инициализация, вызывается один раз за время работы программы
	def Cache.init_global
		@@global_initialized = true
		@@cache_path = File.expand_path(@@cache_path) + '/'
		@@temp_path = File.expand_path(@@temp_path) + '/'

		#TODO удалять каждый файл отдельно с проверкой времени модификации
		#удалить файлы предыдущей сессии
		#FileUtils.remove_dir(@@temp_path, true) #если не удалять, то полное кеширование******************

		#создать каталог для :is_temporal
		FileUtils.mkpath @@cache_path
		FileUtils.mkpath @@temp_path
		#puts "Cache.init_temporal #{@@temp_path}"
	end

 	def cached_file_exists?(file_name, is_temporal)
		return false unless File.exists? file_name

		if is_temporal
			#для временного файла делать проверку на время устаревания
			if Time.now - File.mtime(file_name) > @@temp_expire
				return false
			end
		end
		true
	end

	#сохранить урл в кеш, вернуть путь файла, обработка русских букв
	#http://gz.dvinaland.ru/download/\{C678AB9D-A1C9-4FDA-9392-F304C8163C25}_Техническое задание гемаза.doc
	def save_file_from_url(url)
		fine_name = File.basename(url)
		#запрещены \/  :*?"<>|
		fine_name.gsub!(/[:\*\?"<>|]/, '_')
		puts "\tsave_file_from_url #{fine_name}"

		url = to_utf(URI.escape(to_win(url))) unless url.include? '%' #уже закодирован
		get_url url

		doc_name = cached_file_name(url)

		file_ext = File.extname(doc_name).downcase
		if @packable_files.include? file_ext
			#запаковывать всегда, с коротким именем
			zip_name = File.dirname(doc_name) + '/' + File.basename(doc_name).hash.to_s + '.zip'
	    
			unless File.exists? to_win(zip_name)
				open(doc_name, 'rb') do |ff|
					file_content = ff.read
				end
	    
				#создать ZIP архив и запаковать документ в него
				#NOTE имя файла в dos кодировке
				puts "\tsave as #{zip_name}"
				Zip::ZipFile.open(to_win(zip_name), Zip::ZipFile::CREATE) do |zipfile|
					zipfile.get_output_stream(to_dos(File.basename(fine_name))) do |outfile|
						outfile.write open(doc_name, 'rb').read
					end
				end
			end
			zip_name
		else
			doc_name
		end
	end

	#открыть данную ссылку, сохранить в каталог cache
	#если локальный файл, вернуть его содрежимое
	#NOTE использовать только для html, винарные файлы (DOC) портятся 
	#TODO обработка ошибок
	#TODO для временных задавать параметр время устаревания
	def get_url(url, args = {})
		is_temporal = args[:is_temporal] || false
		use_simple_http = args[:use_simple_http] || false

		puts "Cache.get_url #{url}"

		file_name = cached_file_name(url, is_temporal)
		dat = ''
		if cached_file_exists?(file_name, is_temporal)
			#файл есть в кеше
			puts "\tfound cache #{file_name}"
			open(file_name) do |f|
				dat = f.read
			end
		else
			puts "\tdownload #{url}"

			url = URI(url)

			if url.host.empty?
				#локальный файл
				open(url) do |f|
					dat = f.read
				end
			else
				if use_simple_http
					dat = get_url_http url
				else
					dat = get_url_mechanize(url)
				end

				#сохранение в каталог cache
				dir = File.dirname file_name
				FileUtils.mkpath dir unless File.exists? dir
				open(file_name, 'wb') do |f|
					f.write dat
				end
			end
		end
		dat
	rescue Exception => ex
		save_error ex
		''
	end

	#открыть страницу очереди ссылок
	def get_url_sequence(url_sequence)
		url_sequence = url_sequence.clone
		puts "Cache.get_url_sequence #{url_sequence.inspect}"

		file_name = cached_url_sequence_file_name(url_sequence)
		dat = ''
		if cached_file_exists?(file_name, false)
			#файл есть в кеше
			puts "\tfound cache #{file_name}"
			open(file_name) do |f|
				dat = f.read
			end
		else
			url = url_sequence.shift
			dat = get_url url

			until url_sequence.empty?
				url = url_sequence.shift
				puts "\tdownload #{url}"
				dat = get_url_mechanize(url)
			end

			#сохранение в каталог cache
			dir = File.dirname file_name
			FileUtils.mkpath dir unless File.exists? dir
			open(file_name, 'wb') do |f|
				f.write dat
			end
		end
		dat
	rescue Exception => ex
		save_error ex
		''
	end

	def get_url_post(url, post_args = {})
		puts "Cache.get_url_post(#{url}, #{post_args.inspect})"
		url = URI(url)
		page = @agent.post(url, post_args)
		page.body
	rescue Exception => ex
		save_error ex
		''
	end

	#название файла для конкретного url
	def cached_file_name(url, is_temporal = false)
		file_name = url.to_s.clone
		#запрещены \/  :*?"<>|
		file_name.gsub!(/[:\*\?"<>|]/, '_')
		if (is_temporal)
			file_name.sub!('http_//', @@temp_path)
		else
			file_name.sub!('http_//', @@cache_path)
		end
		file_name
	end

private
	#список ссылок, первый образует каталог и файл, последующие добавляются к имени файла
	def cached_url_sequence_file_name(url_sequence)
		url_sequence = url_sequence.clone
		file_name = cached_file_name url_sequence.shift
		until url_sequence.empty?
			file_name << '___' << url_sequence.shift.gsub(/[:\*\?"<>|\/\\]/, '_')
		end
		file_name
	end

	def get_url_mechanize(url)
		#puts "\t\tget_url_mechanize"
		#page = @agent.get(:url => url)
		page = @agent.get(:url => url, :headers => @headers )
		page.body
	end

	def get_url_http(uri)
		#puts "\t\tget_url_http #{uri}"
		#работает
		res = Net::HTTP.get_response(uri)
		return res.body

		##uri = URI(url)
		#res = Net::HTTP.new(uri.host, uri.port).start do |http|
		#	#http.request_get(uri.request_uri, @headers)
		#	http.request_get(uri.request_uri)
		#end
		##puts res.body
		#return res.body

		#ошибка из-за accept-charset?
		#не работает на http://gz.dvinaland.ru
		#url = URI.parse(url)
		#req = Net::HTTP::Get.new(url.path, @headers)
		#res = Net::HTTP.start(url.host, url.port) {|http| http.request(req) }
		#puts res.body

		#не работает на http://gz.dvinaland.ru
		#url = URI(url)
		#response = Net::HTTP.start(url.host, url.port) do |http|
		#	http.get(url.path)#, @headers)
		#end
		##response = Net::HTTP.get(URI(url), @headers)
		#puts response.body
	end

public
	# Запретить дамп, не работает
	def to_yaml(opts = {}); 'Cache' end
	def to_y(); 'Cache' end
	def ya2yaml(); 'Cache' end

	def test
		#login
		#get_url "http://tenderoff.ru/Operator/OrderEdit.aspx?siteid=68&ordertypeid=3"
		#get_url "OrderEdit.aspx_siteid=68&ordertypeid=3"
		#get_url 'http://gz.dvinaland.ru/tender_conditions.asp?tender_code=2009.030%CE-1', :use_simple_http => true
		#body = get_url 'http://gz.dvinaland.ru/tender_conditions_print.asp?tender_code=2009.030%CE-1' #, :use_simple_http => true
		#body = get_url_http URI('http://gz.dvinaland.ru/tender_conditions_print.asp?tender_code=2009.030%CE-1')

		#проверка загрузки очереди урл
		#url_sequence = ['http://gz.admtyumen.ru/competition/competition.do?action=first&rowId=30982'] #страница тендера
		#url_sequence << 'http://gz.admtyumen.ru/competition/competition.do?tab=3&lot=' #таб с документами
		#puts cached_url_sequence_file_name(url_sequence)     #имя закешированного файла
		#get_url_sequence(url_sequence)      #открыть страницу очереди ссылок
		#get_url url_sequence[0]      #первая страница закеширована

		#сохранить урл в кеш, вернуть путь файла, обработка русских букв
		#http://gz.dvinaland.ru/download/\{C678AB9D-A1C9-4FDA-9392-F304C8163C25}_Техническое задание гемаза.doc
		#path = save_file_from_url('http://gz.dvinaland.ru/download/\{C678AB9D-A1C9-4FDA-9392-F304C8163C25}_Техническое задание гемаза.doc')
		#puts path
	end
end

if $0 == __FILE__
	cache = Cache.new
	cache.test
end
