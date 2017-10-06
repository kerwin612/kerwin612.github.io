@echo off

set "U=U:"
set "RC=.rc"
set "a0a=a0a"

set "ROOT=u~u"
set "CROOT=%~d0\#-#"
set "MROOT=%U%\%ROOT%"
set "UHOME=%MROOT%\%a0a%"
set "CHOME=%CROOT%\%a0a%"
::set "SHOME=%~dp0\"
set "SHOME=%~dp0\..\..\..\"
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

if exist %RHOME% (
	rmdir %RHOME%
)
if exist %UHOME%\env (
	rmdir %UHOME%\env
)
if exist %UHOME%\ext (
	rmdir %UHOME%\ext
)
if exist %UHOME%\.common (
	rmdir %UHOME%\.common
)
mklink /j %RHOME% %~dp0\%RC%
mklink /j %UHOME%\env %~dp0\env
mklink /j %UHOME%\ext %~dp0\ext
mklink /j %UHOME%\.common %~dp0\.common

rem UHOME[U:\!!KERWIN!!\a0a]
echo UHOME[%UHOME%]

cd /d %UHOME%

set _PORTABLEGIT_=PortableGit-2.11.0.1

::cat $(pwd)/.rc/.sshd_config_u > /etc/ssh/sshd_config && 
::echo 'PermitUserEnvironment yes' >> /etc/ssh/sshd_config && 
set "HOME=%RHOME%" && cd.>%RHOME%\.bash_profile && start "" ".\bins\PortableGit\%_PORTABLEGIT_%\git-bash.exe" -c "echo _PORTABLEGIT_[%_PORTABLEGIT_%] && export HOME=$(pwd)/%RC% && echo \"SHOME='%SHOME%'\" > ~/.bash_profile && cat ./env >> ~/.bash_profile && /usr/bin/bash --login -i"