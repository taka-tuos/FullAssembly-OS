TOOLPATH = ../z_tools/
MAKE     = $(TOOLPATH)make.exe -r
NASK     = $(TOOLPATH)nask.exe
MAKEFONT = $(TOOLPATH)makefont.exe
OBJ2BIM  = $(TOOLPATH)obj2bim.exe
EDIMG    = $(TOOLPATH)edimg.exe
IMGTOL   = $(TOOLPATH)imgtol.com
COPY     = copy
DEL      = del

# デフォルト動作

default :
	$(MAKE) img

# ファイル生成規則

ipl10.bin : ipl10.nas Makefile
	$(NASK) ipl10.nas ipl10.bin ipl10.lst

kernel.sys : kernel.nas Makefile
	$(NASK) kernel.nas kernel.bin kernel.lst
	copy kernel.bin kernel.sys

kernel.img : ipl10.bin kernel.sys sample\autoexec.bin Makefile
	$(EDIMG)   imgin:../z_tools/fdimg0at.tek \
		wbinimg src:ipl10.bin len:512 from:0 to:0 \
		copy from:kernel.sys to:@: \
		copy from:sample\autoexec.bin to:@: \
		imgout:kernel.img


# コマンド

img :
	$(MAKE) -C sample
	$(MAKE) kernel.img

run :
	$(MAKE) img
	$(COPY) kernel.img ..\z_tools\qemu\fdimage0.bin
	$(MAKE) -C ../z_tools/qemu

install :
	$(MAKE) img
	$(IMGTOL) w a: kernel.img

clean :
	$(MAKE) -C sample clean
	-$(DEL) ipl10.bin
	-$(DEL) ipl10.lst
	-$(DEL) kernel.sys
	-$(DEL) kernel.bin
	-$(DEL) ascii.bin
	-$(DEL) kernel.lst

src_only :
	$(MAKE) -C sample src_only
	$(MAKE) clean
	-$(DEL) kernel.img
