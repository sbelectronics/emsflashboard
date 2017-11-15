uses dos;

procedure bio_getsize(drive: byte;
                   var size_lo: word;
                   var size_hi: word;
                   var drive_type: byte;
                   var result: byte);
var
  regs: Registers;
begin
  regs.AH := $15;
  regs.DL := drive;
  intr($13, regs);
  result:=regs.AH;
  size_lo:=regs.DX;
  size_hi:=regs.CX;
  drive_type:=regs.AH;
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
  drive_type: byte;
  size_lo, size_hi: word;
  result: byte;

  drive: byte;
  junk: integer;

begin;
  if (paramcount<>1) then begin
    writeln('syntax: testsz <drive>');
    exit;
  end;

  val(paramstr(1), drive, junk);

  bio_getsize(drive, size_lo, size_hi, drive_type, result);
  writeln('getsize result = ', result, ' type = ', drive_type, ' size= ', size_hi, ':', size_lo);
end.