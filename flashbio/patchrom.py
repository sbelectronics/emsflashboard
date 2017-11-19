import string, struct, sys

class Romvars:
    def __init__(self):
        self.fieldnames = ("page_reg", "page_enable", "page_frame_seg", "drive_num", "drive_type", "floppy_type",
                           "num_cyl", "num_head", "num_sec")

        self.format = "<17sxHHHBBBBBB"

    def find_romvars(self, rom): 
        for i in range(0, len(rom)):
           if (rom[i:i+17] == "FLASHBIO_ROM_VARS"):
               return i
        return None

    def load(self,fn):
        rom = open(fn, "rb").read()
        romvars_offset = self.find_romvars(rom)
        if not romvars_offset:
           print >> sys.stderr, "failed to find romvars in", fn
           sys.exit(-1)

        self.romvars_offset = romvars_offset

        (self.romvar_sig, self.page_reg, self.page_enable, self.page_frame_seg, 
         self.drive_num, self.drive_type, self.floppy_type, self.num_cyl, self.num_head, self.num_sec) = \
            struct.unpack(self.format, rom[romvars_offset:romvars_offset+30])

        rom_len = ord(rom[2])*512
        cksum = 0
        for i in range(0, rom_len):
            cksum = cksum + ord(rom[i])
        if (cksum & 0xFF) != 0:
            print "WARNING! BIOS Extension Checksum is Wrong!"
        
    def save(self, fn):
        f = open(fn, "r+b")
        f.seek(self.romvars_offset)

        tmp = struct.pack(self.format, self.romvar_sig, self.page_reg, self.page_enable, self.page_frame_seg,
                          self.drive_num, self.drive_type, self.floppy_type, self.num_cyl, self.num_head, self.num_sec)

        f.write(tmp)

    def dump(self):
        for field_name in self.fieldnames:
           print "  %s = 0x%X" % (field_name, getattr(self, field_name))
        print "  ... disk geometry is %d blocks / %d KB" % ((self.num_cyl*self.num_head*self.num_sec),
                                                        (self.num_cyl*self.num_head*self.num_sec*512/1024))

def fix_cksum(fn):
    data = open(fn, "rb").read()
    rom_len = ord(data[2]) * 512
    cksum = 0
    for i in range(0, rom_len-1):
        cksum=cksum+ord(data[i])
    
    f = open(fn, "r+b")
    f.seek(rom_len-1)
    f.write(struct.pack("=B", 256-(cksum & 0xFF)))

def main():
    fn = sys.argv[1]
    
    romvars = Romvars()
    romvars.load(fn)

    print "Initial:"
    romvars.dump()

    for arg in sys.argv[2:]:
       (name,val) = arg.split("=")
       name=name.strip()
       val=val.strip()

       if "x" in val:
           val = string.atoi(val, 16)
       else:
           val = string.atoi(val)

       setattr(romvars, name, val)

    romvars.save(fn)

    fix_cksum(fn)

    romvars.load(fn)
    print "New:"
    romvars.dump()

if __name__=="__main__": 
    main()
