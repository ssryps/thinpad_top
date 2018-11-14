f_in = open("inst_rom.data", "r")
f_out1 = open("inst_rom1.data", "w")
f_out2 = open("inst_rom2.data", "w")
f_out3 = open("inst_rom3.data", "w")
f_out4 = open("inst_rom4.data", "w")

for line in f_in.readlines():
	f_out2.write(line[0:2] + '\n')
	f_out1.write(line[2:4] + '\n')
	f_out4.write(line[4:6] + '\n')
	f_out3.write(line[6:8] + '\n')
