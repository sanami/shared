

def qt_generate(name)
	input = "#{name}.ui"
	output = "ui_#{name}.rb"

#	puts File.mtime(input)
#	puts File.mtime(output)
	if !File.exists(output) || (File.mtime(input) > File.mtime(output))
		puts "Generating #{output} from #{input}"
		`rbuic4.exe -x #{input} -o #{output}`
	end
end

qt_generate 'qt_threads'
