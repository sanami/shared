require 'Win32API'

module Win32
#	SendMessage = Win32API.new("user32", "SendMessage", ['L'] * 4, 'L')
	SendMessage = Win32API.new('user32', 'SendMessage', ["L", "L", "P", "P"], "L")

end
