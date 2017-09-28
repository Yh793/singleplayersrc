Форк плеера SinglePlayer для WinCE 6.0, ориентированный на работу с китайским ГУ.
Автор оригинальной разработки: alex208210
Ветка на 4PDA: http://4pda.ru/forum/index.php?showtopic=724655

Для запуска кода потребуется:
1) lazarus 1.4: lazarus-1.4.0-fpc-2.6.4-win32.exe
2) fpc 2.6.4: lazarus-1.4.0-fpc-2.6.4-win32.exe
3) пакет библиотек под процессор arm: lazarus-1.4.0-fpc-2.6.4-cross-arm-wince-win32.exe

Для корректного запуска плеера в каталоге с программой должны размещаться следующие билиотеки:
1) aygshell.dll размером 22kb
2) bass.dll
3) bass_aac.dll
4) bass_fx.dll
5) bassalac.dll
6) bassflac.dll
7) tags.dll

Так же не забудьте закинуть папку "Singleplayer" из архива с бинарником в папку с компилируемой программой.