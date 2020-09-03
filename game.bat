cd game
powershell.exe Compress-Archive ./* game.zip
ren game.zip game.love
move game.love ../
cd ..
game.love