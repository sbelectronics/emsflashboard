uses dos;

procedure bio_getparam(drive: byte;
                   var num_cyl: byte;
                   var num_head: byte;
                   var num_sec: byte;
                   var floppy_type: byte;
                   var result: byte);
var
  regs: Registers;
begin
  regs.AH := $8;
  regs.DL := drive;
  intr($13, regs);
  result:=regs.AH;
  num_cyl:=regs.CH;
  num_head:=regs.DH;
  num_sec:=regs.CL;
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
  floppy_type, num_cyl, num_sec, num_head: byte;
  result: byte;

  drive: byte;
  junk: integer;

begin;
  if (paramcount<>1) then begin
    writeln('syntax: testsz <drive>');
    exit;
  end;

  val(paramstr(1), drive, junk);

  bio_getparam(drive, num_cyl, num_head, num_sec, floppy_type, result);
  writeln('getsize result = ', result, ' type = ', floppy_type, ' c = ', num_cyl, ' h = ', num_head, ' s = ', num_sec);
end.