require 'test/unit'
require '../misc.rb'
require '../settings.rb'

# $console_codec = 'ibm866'

class TC_MiscTest < Test::Unit::TestCase
	def setup
		init_logger '../tmp/test_error.log'
		init_codec
	end

	def teardown
	end

	# Проверка сохранения лога при ошибке
	def test_save_error
		begin
			1 / 0
		rescue => ex
			assert_nil save_error(ex)
		end

		begin
			raise 'custom message'
		rescue => ex
			assert_nil save_error(ex)
		end
	end

	def test_codec
		$console_codec = 'ibm866'
		# Проверка print
		#$, = ', ' # разделитель для print
		#$\ = "_\n_"
		print ["старт", "два"], [1, 2, 3], "\n"

		# Проверка puts
		puts "три"

		# Проверка p
		sS = Struct.new(:name, :state)
		s = sS['как', 'так']
		p s

		# Проверка y
		y s
	end

	# rx_unicode.rb, работа со строками в utf8
	def test_unicode
		inspect_rx_unicode
		p to_downcase("Старт")
		p to_upcase("Старт")
	end

	def test_settings
		tmp_file = '../tmp/test_settings.yaml'

		o = Settings.new(tmp_file)
		o.default # Очистить

		# Контейнер
		o.list_of_files << 'first file'
		assert_equal o.list_of_files.size, 1
		assert_equal o.list_of_files[0], 'first file'

		# Контейнер ограниченного размера
		o.list_of_2_items << 1 << 2 << 3
		assert_equal o.list_of_2_items.size, 2
		assert_equal o.list_of_2_items[0], 2
		assert_equal o.list_of_2_items[1], 3

		# Hash
		o.hash_of_items[:files] = '11'
		o.hash_of_items[:google] = 22
		assert_equal o.hash_of_items.size, 2
		assert_equal o.hash_of_items, {:files=>'11', :google=>22}

		# Обычный элемент
		o.some_value = '33'

		assert_equal o.some_value, '33'

		o.save

		oo = Settings.new(tmp_file)
#		y oo
	  assert_equal o.to_hash, oo.to_hash

	end

	def test_yaml
		dat = {}
		name = '../tmp/1.out'
		10.times { |i| dat["ключ #{i}"] = 'значение' }
		open(name, 'wb') { |f| f.write dat.ya2yaml }

		dat = open(name) { |f| YAML.load(f) }
		puts dat.inspect
	end

end
