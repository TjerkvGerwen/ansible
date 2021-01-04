@echo off
net stop spooler
del %windir%\system32\spool\printers\*.* /q
net start spooler
echo Alles zou weer moeten werken