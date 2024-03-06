
@del/q .\Release
@rmdir /s/q .\Release
@mkdir      .\Release

start   .\Tools\srec_cat.exe @.\Tools\Hex2Bin_16896

@copy    .\Objects\*.hex .\Release
@copy    .\Objects\*.bin .\Release
@copy    .\rev.txt       .\Release

start   .\Tools\CheckFileSize.exe .\Release\cy2332r0.bin 16896
