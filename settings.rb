require 'rubygems'
require 'yaml'

# Формат параметров
#	list_of_files
#	list_of_10_files
#TODO hash_of_files
#TODO set_of_files

#TODO	def to_yaml(opts = {})
#TODO	def ya2yaml

class OpenSettings
	module Limited
		def init_limited(size_limit)
			@size_limit = size_limit
		end

		def <<(obj)
			super obj
			if self.size > @size_limit
				self[0...self.size-@size_limit] = nil
			end
			self
		end
	end

	class ItemList
		def initialize
			@items = []
		end

		def method_missing(method, *args)
			@items.method(method).call(*args)
		end
	end

	##
	# Список уникальных объектов
	class UniqueList < ItemList
		def <<(obj)
			if include? obj
				delete obj
			end
			super obj
		end
	end
	
	##
	# Ограниченный список
	class LimitedList < ItemList
		include Limited

		def initialize(size_limit)
			super()
			init_limited(size_limit)
		end
	end

	##
	# Ограниченный список уникальных объектов
	class LimitedUniqueList < UniqueList
		include Limited

		def initialize(size_limit)
			super()
			init_limited(size_limit)
		end

	end

	attr_accessor :properties

	def initialize
		@properties = {}
	end

	##
	# Вернуть свойство по имени, создать если не существует
	def property(prop_name, *args)
		#puts "OpenSettings.property(#{prop_name}, #{args.inspect})"

		if prop_name.to_s =~ /(.+)=$/ # Оператор присваивания
			prop_name = $1.to_sym
		end

		@properties[prop_name] = _create_property(prop_name) unless @properties.has_key? prop_name
		@properties[prop_name] = *args unless args.empty?
		@properties[prop_name]
	end

private
	##
	# Создать свойство, определить тип по имени
	def _create_property(prop_name)
		#puts "OpenSettings._create_property(#{prop_name})"
		case prop_name.to_s # т.к. символ
		when /^list_of_(\d+)_(.+)$/
			LimitedUniqueList.new $1.to_i
		when /^list_of_(.+)$/
			UniqueList.new
		when /^hash_of_(.+)$/
			{}
		else
			nil
		end
	end

=begin
  def _to_hash
    h = @table
    #handles nested structures
    h.each do |k,v|
      if v.class == MoreOpenStruct
        h[k] = v._to_hash
      end
    end
    return h
  end

  def _table
    @table   #table is the hash structure used in OpenStruct
  end

  def _manual_set(hash)
    if hash && (hash.class == Hash)
      for k,v in hash
        @table[k.to_sym] = v
        new_ostruct_member(k)
      end
    end
  end
=end
end

class Settings
	def initialize(file_name)
		@file_path = File.expand_path file_name
		load
	end

	##
	# Настройки по умолчанию
	def default
		@options = OpenSettings.new
	end

#	def to_hash
#		@options.to_hash
#	end

	##
	# Загрузить настройки
	def load
		@options = open(@file_path) { |f| YAML.load(f) }
#		@options.history.instance_eval do
#			##
#			# Элементы по умолчанию
#			def [](a)
#				if include? a
#					super
#				else
#					self[a] = []
#				end
#			end
#		end
	rescue
		default
	end

	##
	# Сохранить настройки
	def save
		open(@file_path, 'w') { |f| YAML.dump(@options, f) }
	end

private
	##
	# Передать вызовы методов внутреннему объекту
	def method_missing(method, *args)
		#puts "Settings.method_missing(#{method}, #{args.inspect})"
		@options.property(method, *args)
	end

end
