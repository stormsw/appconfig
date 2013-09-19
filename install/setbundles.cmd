@ECHO OFF
ruby -v
call gem --version
rem call gem update --system
rem call gem update
call gem install bundler
call gem source -a http://av:8808
call gem source -a http://ov:8808
call gem install lrs-appconfig
call appconfig help
pause