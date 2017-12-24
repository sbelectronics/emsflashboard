uses dos;

type
  tdpt = record
         head_unload: byte;
         head_load: byte;
         motor_wait: byte;
         bytes_sec: byte;
         sec_trk: byte;
         gap: byte;
         data_len: byte;
         gap_len: byte;
         fill_byte: byte;
         head_sett: byte;
         motor_st: byte;
        end;
  pdpt = ^tdpt;

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

procedure bio_write(drive: byte;
                   cylinder: byte;
                   head: byte;
                   sector: byte;
                   count: byte;
                   src: pointer;
                   var result: byte);
var
  regs: Registers;
begin
  regs.AH := 3;
  regs.AL := count;
  regs.CH := cylinder;
  regs.CL := sector;
  regs.DH := head;
  regs.DL := drive;
  regs.ES := Seg(src^);
  regs.BX := Ofs(src^);
  intr($13, regs);
  result:=regs.AH;
end;


procedure bio_getparam(drive: byte;
                   var num_cyl: byte;
                   var num_head: byte;
                   var num_sec: byte;
                   var floppy_type: byte;
                   var dpt: pdpt;
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
  dpt:=ptr(regs.ES, regs.DI);
end;

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

procedure print_hex_word(w: word);
begin
  print_hex_byte(w shr 8);
  print_hex_byte(w and $ff);
end;

procedure print_pointer(p: pointer);
begin
  print_hex_word(seg(p^));
  write(':');
  print_hex_word(ofs(p^));
end;


var
  i: integer;
  p: ^byte;
  result: byte;

  drive, c, h, s, floppy_type: byte;
  drive_type: byte;
  size_lo, size_hi: word;
  junk: integer;
  tmp_str: string;
  dpt: pdpt;

procedure showhelp;
begin
    writeln('syntax: testbio <cmd>');
    writeln('          read <drive> <cyl> <head> <sec>');
    writeln('          getparam <drive>');
    writeln('          getsize <drive>');
    writeln('          getdpt <drive>');
end;


begin;
  if (paramcount<2) then begin
    showhelp;
    exit;
  end;

  if (paramstr(1)='read') then begin
    if (paramcount<>5) then begin
        showhelp;
        exit;
    end;

    val(paramstr(2), drive, junk);
    val(paramstr(3), c, junk);
    val(paramstr(4), h, junk);
    val(paramstr(5), s, junk);

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
  end else if (paramstr(1)='write') then begin
    if (paramcount<>6) then begin
        showhelp;
        exit;
    end;

    val(paramstr(2), drive, junk);
    val(paramstr(3), c, junk);
    val(paramstr(4), h, junk);
    val(paramstr(5), s, junk);

    getmem(p, 4096);
    fillchar(p^, 4096, $FE);

    tmp_str := paramstr(6);
    move(tmp_str, p^, length(tmp_str));

    bio_write(drive, c, h, s, 1, p, result);
    writeln('write result = ', result);
  end else if (paramstr(1) = 'getparam') then begin
    if (paramcount<>2) then begin;
        showhelp;
        exit;
    end;

    val(paramstr(2), drive, junk);

    bio_getparam(drive, c, h, s, floppy_type, dpt, result);

    writeln('getparam result = ', result, ' type = ', floppy_type, ' c = ', c, ' h = ', h, ' s = ', s);
  end else if (paramstr(1) = 'getdpt') then begin
    if (paramcount<>2) then begin;
        showhelp;
        exit;
    end;

    val(paramstr(2), drive, junk);

    bio_getparam(drive, c, h, s, floppy_type, dpt, result);

    write('dpt_addr = ');
    print_pointer(dpt);
    writeln;
    writeln('head_unload = ', dpt^.head_unload);
    writeln('head_load = ', dpt^.head_load);
    writeln('motor_wait = ', dpt^.motor_wait);
    writeln('bytes_sec = ', dpt^.bytes_sec);
    writeln('sec_trk = ', dpt^.sec_trk);
    writeln('gap = ', dpt^.gap);
    writeln('data_len = ', dpt^.data_len);
    writeln('gap_len = ', dpt^.gap_len);
    writeln('fill_byte = ', dpt^.fill_byte);
    writeln('head_sett = ', dpt^.head_sett);
    writeln('motor_st = ', dpt^.motor_st);
  end else if (paramstr(1) = 'getsize') then begin;
    if (paramcount<>2) then begin;
      showhelp;
      exit;
    end;

    val(paramstr(2), drive, junk);

    bio_getsize(drive, size_lo, size_hi, drive_type, result);
    writeln('getsize result = ', result, ' type = ', drive_type, ' size= ', size_hi, ':', size_lo);
  end;
end.