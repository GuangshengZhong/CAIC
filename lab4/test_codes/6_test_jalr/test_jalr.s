    jalr x10, 28(x0) # jump to tag1 # 000000011100 00000 000 01010 1100111

tag2: 
    addi x12, x12, 2 # 000000000010 01100 000 01100 0010011
    sw x10, 8(x0) # 0000000 01010 00000 010 01000 0100011
    sw x12, 12(x0) # 0000000 01100 00000 010 01100 0100011
    auipc x10, 0x1 # 00000000000000000001 01010 0010111
    jalr x10, -16(x10) # jump to tag3 # 111111110000 01010 000 01010 1100111

    xor x10, x10, x10 # 0000000 01010 01010 100 01010 0110011

tag1:
    addi x11, x11, 1 # 000000000001 01011 000 01011 0010011
    sw x10, 0(x0) # 0000000 01010 00000 010 00000 0100011
    sw x11, 4(x0) # 0000000 01011 00000 010 00100 0100011
    auipc x10, 0x0 # 00000000000000000000 01010 0010111
    jalr x10, -36(x10) # jump to tag2 # 111111011100 01010 000 01010 1100111

tag3: # assume the address is 0x1000
    addi x13, x13, 3 # 000000000011 01101 000 01101 0010011
    sw x10, 16(x0) # 0000000 01010 00000 010 10000 0100011
    sw x13, 20(x0) # 0000000 01101 00000 010 10100 0100011