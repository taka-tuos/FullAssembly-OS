TOOLPATH = ../../z_tools/
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
	$(MAKE) bin

# ファイル生成規則

autoexec.bin : autoexec.nas Makefile
	$(NASK) autoexec.nas autoexec.bin autoexec.lst

# コマンド

bin :
	$(MAKE) autoexec.bin

clean :
	-$(DEL) autoexec.lst

src_only :
	$(MAKE) clean
	-$(DEL) autoexec.bin
