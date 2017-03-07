require 'wmi-lite'
# value row
cores = 0

#sets up wmi for everything 
wmi = WmiLite::Wmi.new
# gets the number of cores on the system
processors = wmi.instances_of('Win32_Processor')
processors.each do | processor |
  cores += processor['numberofcores']
end
#finds out if part of a domain 
computer_system = wmi.first_of('Win32_ComputerSystem')
is_in_domain = computer_system['partofdomain']
memory_installed = computer_system['totalphysicalmemory']
computer_name = computer_system['name']
logical_processors = computer_system['numberoflogicalprocessors']


out_file= File.new("#{computer_name}_system_info.txt","a")
out_file.puts("System information for #{computer_name}\n\n\n\n\n\n")
out_file.puts("---------------System Status-----------------------")
out_file.puts("the system has #{cores} core(s).\n")
out_file.puts("the system has #{memory_installed} of memory installed ")
out_file.puts("\n\n\n---------------Info on domain status----------------")
out_file.puts("This system is #{is_in_domain ? '' : 'not '}domain joined.\n")



# local users on the box and if they are disabled 
out_file.puts("\n\n\n---------------Local Users-----------------------")
local_accounts = wmi.query('Select * from Win32_UserAccount Where LocalAccount = True')
out_file.puts("\n#{'User Name'.ljust(40)}\tDisabled")
out_file.puts("#{'----------'.ljust(40)}\t----\n")
local_accounts.each do | account |
  username = account['name']
  disabled = account['disabled']
  out_file.puts("#{username.ljust(40)}\t#{disabled}")
end 

#  gets gpo status 
out_file.puts("\n\n\n---------------Group Policies on the computer-----------------------")
gpo = WmiLite::Wmi.new('root\rsop\computer')
gpos = gpo.instances_of('RSOP_GPO')
out_file.puts("\n#{'GPO Id'.ljust(40)}\tName")
out_file.puts("#{'------'.ljust(40)}\t----\n")
gpos.each do | gpo |
  gpo_id = gpo['guidname']
  gpo_display_name = gpo['name']
  out_file.puts("#{gpo_id.ljust(40)}\t#{gpo_display_name}")
end


#software installed 
out_file.puts("\n\n\n---------------Software Installed-----------------------")
installed_software = wmi.query('Select * from Win32_Product')
out_file.puts("\n#{'Software Name'.ljust(40)}\t\tinstall location")
out_file.puts("#{'----------'.ljust(40)}\t#{'-----------'.ljust(40)}\t---------\n")
installed_software.each do | software |
  software_name = software['name']
  installed_location = software['localpackage']
  out_file.puts("#{software_name}\t\t#{installed_location}")
end 

