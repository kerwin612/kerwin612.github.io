@echo off

set "U=U:"
set "_RC=.rc"
set "RC=.rc-cygwin"
set "a0a=a0a"

set "ROOT=u~u"
set "CROOT=%~d0\#-#"
set "MROOT=%U%\%ROOT%"
set "UHOME=%MROOT%\%a0a%"
set "CHOME=%CROOT%\%a0a%"
::set "SHOME=%~dp0\"
set "SHOME=%~dp0\..\..\..\"
set "_RHOME=%UHOME%\%_RC%"
set "RHOME=%UHOME%\%RC%"


if exist %CROOT% (
	rd /s /q %CROOT%
)

if not exist %CROOT% (
	mkdir %CROOT%
)


if exist %U% (
	if "%~d0"=="%U%" (
		echo "U:"存在且就是当前盘
	) else (
		echo "U:"存在但不是当前盘
	)
	if exist %MROOT% (
		rd /s /q %MROOT%
	)
) else (
	echo "U:"不存在
	subst %U% /D
	subst %U% %CROOT%	
)

mklink /j %MROOT% %CROOT%
mklink /j %CHOME% %SHOME%

if exist %_RHOME% (
	rmdir %_RHOME%
)
if exist %RHOME% (
	rmdir %RHOME%
)
if exist %UHOME%\env-cygwin (
	rmdir %UHOME%\env-cygwin
)
if exist %UHOME%\ext-cygwin (
	rmdir %UHOME%\ext-cygwin
)
mklink /j %_RHOME% %~dp0\%_RC%
mklink /j %RHOME% %~dp0\%RC%
mklink /j %UHOME%\env-cygwin %~dp0\env-cygwin
mklink /j %UHOME%\ext-cygwin %~dp0\ext-cygwin

rem UHOME[U:\!!KERWIN!!\a0a]
echo UHOME[%UHOME%]

cd /d %UHOME%

::cat $(pwd)/.rc/.sshd_config_u > /etc/ssh/sshd_config && 
::echo 'PermitUserEnvironment yes' >> /etc/ssh/sshd_config && 
set "HOME=%RHOME%" && cd.>%RHOME%\.bash_profile && start "" ".\bins\Cygwin\bin\mintty.exe" -e /usr/bin/bash --login -i -c "export HOME=$(pwd) && echo \"SHOME='%SHOME%'\" > ~/.bash_profile && cat $HOME/../env-cygwin >> ~/.bash_profile && /usr/bin/bash --login -i"