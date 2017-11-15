uses dos;

procedure bio_read(drive: byte;
                   cylinder: byte;
                   head: byte;
                   sector: byte;
                   count: byte;
                   dest: pointer;
                   var result: byte);
var
  regs: Registers;
begin
  regs.AH := 2;
  regs.AL := count;
  regs.CH := cylinder;
  regs.CL := sector;
  regs.DH := head;
  regs.DL := drive;
  regs.ES := Seg(dest^);
  regs.BX := Ofs(dest^);
  intr($13, regs);
  result:=regs.AH;
end;

procedure print_hex_digit(b: byte);
begin
  if (b<10) then begin
      write(chr(b+ord('0')));
  end else begin
      write(chr(b-10+ord('A')));
  end;
end;

procedure print_hex_byte(b: byte);
begin
  print_hex_digit(b shr 4);
  print_hex_digit(b and $0f);
end;

var
  i: integer;
  p: ^byte;
  result: byte;

  drive, c, h, s: byte;
  junk: integer;

begin;
  if (paramcount<>4) then begin
    writeln('syntax: testbio <drive> <cyl> <head> <sec>');
    exit;
  end;

  val(paramstr(1), drive, junk);
  val(paramstr(2), c, junk);
  val(paramstr(3), h, junk);
  val(paramstr(4), s, junk);

  getmem(p, 4096);
  fillchar(p^, 4096, $FE);
  bio_read(drive, c, h, s, 1, p, result);
  writeln('read result = ', result);

  for i:=0 to 127 do begin
    print_hex_byte(p^);
    write(' ');
    inc(p);
    if ((i+1) mod 16) = 0 then writeln;
  end;
end.