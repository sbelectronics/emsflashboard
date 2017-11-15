f = open("flashbio.bin", "rb")
byte = f.read(1)
cksum = 0
while byte:
  cksum=cksum+ord(byte[0])
  byte = f.read(1)
print "%X" % cksum
