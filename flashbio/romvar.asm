page_reg     	DW	260h
page_enable     DW      264h
page_frame_seg	DW	0E000h
drive_num       DB      1h        ; first floppy

drive_type      DB      2         ; floppy, can detect change (func 15h)
floppy_type     DB      1h        ; 360K floppy (func 08h)
num_cyl         DB      40
num_head        DB      2
num_sec         DB      9

dpt:
dpt_head_unload DB      0             ; unload=32ms, steprate=2ms
dpt_head_load   DB      1             ; unload=4ms, 1=no dma used
dpt_motor_wait  DB      0             ; 0 ticks
dpt_bytes_sec   DB      2             ; 512 bytes per sector
dpt_sec_trk     DB      9             ; 9 sectors per track
dpt_gap         DB      0
dpt_data_len    DB      0FFh
dpt_gap_len_f   DB      0
dpt_fill_byte   DB      0F6h
dpt_head_sett   DB      0
dpt_motor_st    DB      0

