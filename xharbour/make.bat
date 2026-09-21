@echo off

cd build
copy ..\*.prg /y

set XHB_PATH=D:\xHarbour
set MINGW_PATH=D:\mingw64
set PATH=%MINGW_PATH%\bin;%XHB_PATH%\bin;%PATH%

echo [0] Limpando...
if exist *.exe del *.exe
if exist *.o   del *.o
if exist *.c   del *.c

echo [1] Ponto de Entrada...
echo extern void hb_cmdargInit( int argc, char **argv ); > _main.c
echo extern void hb_vmInit( int bStart ); >> _main.c
echo extern int hb_vmQuit( void ); >> _main.c
echo int main( int argc, char **argv ) { hb_cmdargInit(argc, argv); hb_vmInit(1); return hb_vmQuit(); } >> _main.c

echo [2] Compilando PRGs...
harbour.exe legado_repository.prg -q -i%XHB_PATH%\include
harbour.exe legado_ui.prg         -q -i%XHB_PATH%\include
harbour.exe rest_repository.prg   -q -i%XHB_PATH%\include
harbour.exe rest_server.prg       -q -i%XHB_PATH%\include
harbour.exe simula.prg            -q -i%XHB_PATH%\include

echo [3] GCC...
gcc.exe -m64 -c legado_repository.c -I%XHB_PATH%\include -o legado_repository.o
gcc.exe -m64 -c legado_ui.c         -I%XHB_PATH%\include -o legado_ui.o
gcc.exe -m64 -c rest_repository.c   -I%XHB_PATH%\include -o rest_repository.o
gcc.exe -m64 -c rest_server.c       -I%XHB_PATH%\include -o rest_server.o
gcc.exe -m64 -c simula.c            -I%XHB_PATH%\include -o simula.o
gcc.exe -m64 -c _main.c -o _main.o

echo [4] Linkando EXEs...
set LIBS=-L%XHB_PATH%\lib -Wl,--start-group -lvm -lrtl -lgtwin -llang -lrdd -lmacro -lpp -lcommon -ldbfntx -ldbffpt -lhbsix -lusrrdd -ltip -lpcrepos -lzlib -lws2_32 -lwinmm -lpthread -Wl,--end-group -luser32 -lwinspool -lole32 -loleaut32 -luuid
gcc.exe -m64 -mconsole legado_ui.o legado_repository.o _main.o -o legado_ui.exe %LIBS%
gcc.exe -m64 -mconsole rest_server.o rest_repository.o legado_repository.o _main.o -o rest_server.exe %LIBS%
gcc.exe -m64 -mconsole simula.o rest_repository.o legado_repository.o _main.o -o simula.exe %LIBS%

if exist rotas.dbf del rotas.dbf
echo [OK] Pronto!

simula.exe
start "Ngrok Server" cmd /k "ngrok http --domain=truck-devoutly-native.ngrok-free.dev 8080"
rest_server.exe