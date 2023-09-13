
.\Tools\srec_cat.exe ^
   -Disable_Sequence_Warnings ^
   .\Objects\cy2332r0.hex ^
   -Intel ^
   -fill 0xFF 0 %1 ^
   -Output_Block_Size=16 ^
   -address-length=2 ^
   -o .\Objects\cy2332r0.bin ^
   -Binary

@del/q .\Release
@rmdir /s/q .\Release
@mkdir .\Release
@copy/y .\Objects\cy2332r0.bin .\Release
@copy/y .\Objects\cy2332r0.hex .\Release
@copy/y .\rev.txt .\Release

.\Tools\CheckFileSize.exe .\Release\cy2332r0.bin %1
