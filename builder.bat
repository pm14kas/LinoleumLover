cd builder
powershell.exe Compress-Archive ./* builder.zip
ren builder.zip builder.love
move builder.love ../
cd ..
builder.love