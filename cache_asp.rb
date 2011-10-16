require 'rubygems'
require 'mechanize'
require 'misc.rb'
require 'cache.rb'

#модификация для работы с ASP.NET формами, требует POST со служебными данными
#скрытое кеширование, т.к. все загруженные страницы хранятся в памяти
class CacheAsp < Cache
	class PostPages
		attr_accessor :page    #страница WWW::Mechanize::Page
		attr_accessor :sub_pages  #список POST параметров  => PostPages

		def initialize()
			@sub_pages = {}
		end
	end

	def initialize()
		super

		#загруженные страницы
		@pages = {} #url => PostPages
	end

	#страница из списка параметров, изменяет params_history, использовать clone
	#NOTE page.form сохраняет POST параметры, чистить после запроса
	def get_url(url, params_history = [], form_name = 'aspnetForm', page = nil)
		params_history = params_history.clone
		puts "CacheAsp.get_url #{url} #{params_history.inspect}"

		unless @pages.has_key? url
			@pages[url]	= PostPages.new
			@pages[url].page = @agent.get(url)
		end

		page = @pages[url] unless page

		params = params_history.shift
		if params
			unless page.sub_pages.has_key? params
				page.sub_pages[params] = PostPages.new
				page.sub_pages[params].page = page.page.form_with(:name => form_name) do |form|
					params.each do |key, val|
						#добавление POST полей
						form[key] = val
					end
				end.submit

				#удаление добавленных POST полей
				page.page.form_with(:name => form_name) do |form|
					params.each do |key, val|
						form.delete_field! key
					end
				end

				page_url = page.sub_pages[params].page.uri.to_s
				if page_url != url && !@pages.has_key?(page_url)
					puts "\tnew url #{page_url}"
					#сохранить данные также и под новым урл
					@pages[page_url] = page.sub_pages[params] 
				end
			end

			page = page.sub_pages[params]
		end

		if params_history.empty?
			page.page
		else
			get_url(url, params_history, form_name, page)
		end
	end

	def get_page(page, params = {}, form_name = 'aspnetForm')
		puts "CacheAsp.get_page(#{page.uri}, #{params.inspect})"
		#запрос с добавленными POST полями
		post_page = page.form_with(:name => form_name) do |form|
			params.each do |key, val|
				#добавление POST полей
				form[key] = val
			end
		end.submit

		#удаление добавленных POST полей
		page.form_with(:name => form_name) do |form|
			params.each do |key, val|
				form.delete_field! key
			end
		end

		post_page
	end

public
	def test
		list_url = 'http://gostorgi.tver.ru/Tender/Purchase.aspx?LevelId=1'
		tender_url = 'http://gostorgi.tver.ru/Tender/ViewPurchase.aspx?PurchaseId=3604&LevelId=1'
		lot_url = 'http://gostorgi.tver.ru/Tender/ViewBid.aspx?BidId=10660&LevelId=1'

		#тендер номер 10
		puts 11
		history = [];
		history << { 'ctl00$phWorkZone$New$ctl11$btEdit.x' => '7', 'ctl00$phWorkZone$New$ctl11$btEdit.y' => '7' }
		page = get_url(list_url, history)
		open('11.htm', 'w').write(page.body)

		#тендер номер 8
		puts 8
		history = [];
		history << { 'ctl00$phWorkZone$New$ctl08$btEdit.x' => '7', 'ctl00$phWorkZone$New$ctl08$btEdit.y' => '7' }
		page = get_url(list_url, history)
		open('8.htm', 'w').write(page.body)


		##список лотов тендера
		#puts 1
		#history = [];
		#history << { '__EVENTTARGET' => 'ctl00$phWorkZone$New', '__EVENTARGUMENT' => 'Page$2' }
		#history << { 'ctl00$phWorkZone$New$ctl02$btEdit.x' => '7', 'ctl00$phWorkZone$New$ctl02$btEdit.y' => '7' }
		#history << { 'ctl00$phWorkZone$menu$__theTabStrip$ctl01$__theTab' => 'Лоты' }
		#page = get_url(list_url, history)
		#open('1.htm', 'w').write(page.body)

		##запрос закешированной страницы, список тендеров
		#puts 2
		#history = [];
		#page = get_url(list_url, history)
		#open('2.htm', 'w').write(page.body)
		#
		##страница тендера Карточка закупки по прямой ссылке
		#puts 3
		#page = get_url(tender_url)
		#open('3.htm', 'w').write(page.body)
		#
		##страница тендера Лоты
		#puts 4
		#history = [];
		#history << { 'ctl00$phWorkZone$menu$__theTabStrip$ctl01$__theTab' => 'Лоты' }
		#page = get_url(tender_url, history)
		#open('4.htm', 'w').write(page.body)

		##загрузка файла
		#puts 5
		#history = [];
		#history << { 'ctl00$phWorkZone$gridDoc1$ctl02$ImageButton1.x' => '7', 'ctl00$phWorkZone$gridDoc1$ctl02$ImageButton1.y' => '7' }
		#page = get_url(tender_url, history)
		#open('5', 'wb').write(page.body)

		#сериализация
		#open('dump.yaml', 'w') { |f| YAML.dump(page, f) }
	end
end

if $0 == __FILE__
	cache = CacheAsp.new
	cache.test
end
