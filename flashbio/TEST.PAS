uses
  crt;
const
  WINDOW_ADDR = $E000;
  BANK_REG = $260;
var
  R: word;

procedure set_bank(window: integer; bank: integer);
begin
  port[BANK_REG + window] := bank;
end;

procedure enable_bank;
begin;
  port[BANK_REG + 4] := 1;
end;

procedure write_flash_byte(window: word; chip: word; offset: longint; b: byte);
var
  off_bank: word;
begin
  off_bank:=offset div 16384;
  offset:=offset mod 16384;
  set_bank(window, chip*32 + off_bank);
  { writeln('wb ', chip*32+off_bank, ' ', offset, ' ',b); }
  mem[WINDOW_ADDR:(window*16384+offset)]:=b;
end;

procedure erase_flash(window: word; chip: word);
begin
  write_flash_byte(window, chip, $5555, $AA);
  write_flash_byte(window, chip, $2AAA, $55);
  write_flash_byte(window, chip, $5555, $80);
  write_flash_byte(window, chip, $5555, $AA);
  write_flash_byte(window, chip, $2AAA, $55);
  write_flash_byte(window, chip, $5555, $10);
  delay(100);
end;

procedure program_flash_byte(window: word; chip: word; offset: longint; b: byte);
var
  readback, last_readback: byte;
begin
  write_flash_byte(window, chip, $5555, $AA);
  write_flash_byte(window, chip, $2AAA, $55);
  write_flash_byte(window, chip, $5555, $A0);
  write_flash_byte(window, chip, offset, b);

  readback:=mem[WINDOW_ADDR:(window*16384)];
  repeat
    last_readback:=readback;
    readback:=mem[WINDOW_ADDR:(window*16384)];
  until (last_readback and 64) = (readback and 64);
end;

procedure program_flash_string(window: word; chip: word; offset: longint; astr: string);
var
  i: integer;
begin
  for i:=1 to length(astr) do begin
    program_flash_byte(window, chip, offset, ord(astr[i]));
    offset:=offset+1;
  end;
  program_flash_byte(window, chip, offset, 0);
end;

function itoa(x: integer): string;
var
  s: string;
begin
  str(x, s);
  itoa:=s;
end;

procedure initialize;
var
  i,j: integer;
begin
  R:=random(100);
  erase_flash(0,0);
  for i:=0 to 31 do begin
    writeln('init bank ', i);
    j:=32;
    while (j<16000) do begin
       program_flash_byte(1, i div 32, longint(i mod 32)*longint(16384)+j, (i+j+R) mod 256);
       j:=j+151; { increase by a prime number, 151, so this gets done in reasonable time }
    end;
    program_flash_string(1, i div 32, longint(i mod 32)*longint(16384), 'Bank ' + itoa(i));
  end;
end;

procedure readback;
var
  i,j: integer;
  b: byte;
begin
  for i:=0 to 31 do begin
    writeln('verify bank', i);
    set_bank(1,i);
    j:=32;
    while (j<16000) do begin
      b:=mem[WINDOW_ADDR:16384+j];
      if b <> ((i+j+R) mod 256) then begin
          writeln('mismatch ', i, ' ', j, ' ', b, ' ', (i+j+R) mod 256);
      end;
      j:=j+151; { step by a prime}
    end;
  end;
end;


procedure dump_bank(window: integer; bank: integer);
var
  i: integer;
  b: byte;
begin
  set_bank(window, bank);
  write('  window ', window, ' bank ', bank, ': ');
  i:=0;
  repeat
    b := mem[WINDOW_ADDR:window*16384 + i];
    if (b<>0) and (b<>255) then begin
      write(chr(b));
    end;
    i:=i+1;
  until (b=0) or (i=16384);
  writeln;
end;

procedure dump_test;
begin
  writeln('a few dump tests...');
  dump_bank(0,0);
  dump_bank(0,1);
  dump_bank(0,4);
  dump_bank(2,2);
  dump_bank(3,3);
end;


begin;
   writeln('flash test');
   randomize;
   enable_bank;
   initialize;
   readback;
   dump_test;
end.