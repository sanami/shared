# encoding: utf-8

module Qt
	##
	# Загрузить код файла ресурса
  def self.require(name, output_dir = nil)
		ext_name = ::File.extname name
		base_dir = ::File.dirname name
		output_dir ||= base_dir
		base_name = ::File.basename(name, ext_name)
	  rb_name = case ext_name
		  when '.ui'
	      generate_ui base_dir, base_name, output_dir
		  when '.qrc'
	      generate_qrc base_dir, base_name, output_dir
		  else
	      raise "Unknown extension for #{name}"
	  end
		Kernel.require rb_name
	end	

  ##
  # Сгенерировать код формы
	def self.generate_ui(base_dir, name, output_dir)
		input = "#{base_dir}/#{name}.ui"
		output = "#{output_dir}/ui_#{name}.rb"

		if need_generate?(input, output)
			puts "Generating #{output} from #{input}"
			# Options: rbuic4 -h
			`rbuic4 #{input} -o #{output}`
		end
		
		output
	end

  ##
  # Сгенерировать код ресурса
  def self.generate_qrc(base_dir, name, output_dir)
	  input = "#{base_dir}/#{name}.qrc"
	  output = "#{output_dir}/qrc_#{name}.rb"

	  if need_generate?(input, output)
		  puts "Generating #{output} from #{input}"
		  `rbrcc #{input} -o #{output}`
	  end

	  output
  end

  ##
  # Если файла не существует или устарел
  def self.need_generate?(input, output)
		!::File.exist?(output) || (::File.mtime(input) > ::File.mtime(output))
  end
end
