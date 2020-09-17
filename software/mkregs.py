#!/usr/bin/python2.7
#
#    Build Latex tables of verilog module interface signals and registers
#

import sys
import os.path
import re
import math

def write_mapping(name_map, width_map, init_val_map, type_map):
    #write output file
    fout = open ('sw_reg_gen.v', 'w')

    fout.write("//This file was generated by script swreg2regmap.py\n\n")

    fout.write("//write registers\n")
    for i in range(len(name_map)):
        if (type_map[i] == "`W_TYP" or type_map[i] == "`RW_TYP"):
            fout.write("`REG_ARE(clk, rst, " + str(init_val_map[i]) + ", valid & wstrb & (address == " + str(i) + "), " + str(name_map[i]) + ", wdata[" + str(width_map[i]) + "-1:0])\n")
            pass
        pass
        
    fout.write("\n\n//read registers\n")
    fout.write("`SIGNAL(rdata_int,`DATA_W)\n")
    fout.write("`SIGNAL2OUT(rdata, rdata_int)\n\n")

    fout.write("always @* begin\n")
    fout.write("   rdata_int = `DATA_W'd0;\n")
    fout.write("   case(address)\n")
    for i in range(len(name_map)):
        if (type_map[i] == "`R_TYP" or type_map[i] == "`RW_TYP"):
            fout.write("     " + str(i) + ": rdata_int = " + str(name_map[i]) + " | `DATA_W'd0;\n")
            pass
        pass
    fout.write("     default: rdata_int = `DATA_W'd0;\n")
    fout.write("   endcase\n")
    fout.write("end\n")

    fout.close()
    return

def write_weights(name_map, width_map):
    fout = open('sw_reg_w.vh', 'w')
    
    fout.write("//This file was generated by script swreg2regmap.py\n\n")
    fout.write("//address width\n")
    addr_w = int(math.ceil(math.log(len(name_map))/math.log(2)))
    fout.write("`define ADDR_W " + str(addr_w) + "\n")
    
    fout.write("\n//registers width\n")
    for i in range(len(name_map)):
        fout.write("`define " + str(name_map[i]) + "_W " + str(width_map[i]) + "\n")
        
    fout.close()
    return

def write_h(name_map):
    fout = open('sw_reg.h', 'w')

    fout.write("//This file was generated by script swreg2regmap.py\n\n")
    fout.write("//register address mapping\n")
    for i in range(len(name_map)):
        fout.write("#define " + str(name_map[i]) + " " + str(i) + "\n")
        
    fout.close()
    return


def swreg_parse (program, hwsw):
    name_map = []
    width_map = []
    init_val_map = []
    type_map = []
    for line in program :
        subline = re.sub('\[|\]|:|,|//|\;',' ', line)
        subline = re.sub('\(',' ',subline, 1)
        subline = re.sub('\)',' ', subline, 1)

        flds = subline.split()
        if not flds : continue #empty line
        #print flds[0]
        if ('SWREG_' in flds[0]): #software accessible registers
            reg_name = flds[1] #register name
            reg_width = flds[2] #register width
            reg_init_val = flds[3] #register init val

            #register type
            if '_RW' in flds[0]:
                reg_type = '`RW_TYP'
            elif '_W' in flds[0]:
                reg_type = '`W_TYP'
            else:
                reg_type = '`R_TYP'


            name_map.append(reg_name)
            width_map.append(reg_width)
            init_val_map.append(reg_init_val)
            type_map.append(reg_type)
        else: continue #not a recognized macro

    if(hwsw == "HW"):
        write_mapping(name_map, width_map, init_val_map, type_map)
        write_weights(name_map, width_map)
    elif(hwsw == "SW"):
        write_h(name_map)
    return

def main () :
    #parse command line
    if len(sys.argv) != 3:
        print("Usage: ./swreg2regmap.py infile [HW/SW]")
        quit()
    else:
        infile = sys.argv[1]
        hwsw = sys.argv[2]
        
    #parse input file
    fin = open (infile, 'r')
    program = fin.readlines()
    fin.close()

    swreg_parse (program, hwsw)

if __name__ == "__main__" : main ()
