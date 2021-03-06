@echo off
mode 78,45
setlocal enabledelayedexpansion
set "home=%~dp0"
cd /d "%home%"
set "sfk=bin\sfk.exe"
set "action=           "
set "UIscooter=    "
set "device=          "
set "UIchip=        "
call :MIDUHEAD


@echo test>WritePermTest
if not exist WritePermTest (
	color 4
	@echo No writing permission in^:
	@echo.
	@echo  - %home% -
	@echo.
	@echo Please move MiDu-Flasher to C^:^\
	@echo.
	pause
	exit
	) else (
	del WritePermTest	
	)


REM -------------------------------------------------------

:MIDUSELTAR
set "action=           "
set "UIscooter=    "
set "device=          "
set "UIchip=        "
call :MIDUHEAD
@echo  Select Target
@echo.
@echo  1 = Dashboard
@echo  2 = Controller
@echo  3 = BMS
@echo.

choice /c 123e /n /m "Press [1],[2],[3] or [e] to exit"
if "%ERRORLEVEL%" == "1" set "device=Dashboard "
if "%ERRORLEVEL%" == "2" (
	set "device=Controller"
	@echo.
	@echo Only Dashboard is supported yet
	@echo.
	pause
	goto :MIDUSELTAR
	) 
if "%ERRORLEVEL%" == "3" (
	set "device=BMS       "
	@echo.
	@echo Only Dashboard is supported yet
	@echo.
	pause
	goto :MIDUSELTAR
	)
if "%ERRORLEVEL%" == "4" goto :MIDUEND
if "%ERRORLEVEL%" == "255" @echo ERROR & pause & goto :MIDUSELTAR

REM -------------------------------------------------------

:MIDUSELACT
set "action=           "
set "UIscooter=    "
set "UIchip=        "
call :MIDUHEAD
@echo  Select an Action
@echo.
@echo  1 = Downgrade
@echo  2 = Dump Flash
@echo  3 = Write Flash
@echo.

choice /c 123b /n /m "Press [1],[2],[3] or [b] for back"
if "%ERRORLEVEL%" == "1" set "action=Downgrade  "
if "%ERRORLEVEL%" == "2" set "action=Dump Flash "
if "%ERRORLEVEL%" == "3" set "action=Write Flash"
if "%ERRORLEVEL%" == "4" goto :MIDUSELTAR
if "%ERRORLEVEL%" == "255" @echo ERROR & pause & goto :MIDUSELACT

REM -------------------------------------------------------

:MIDUSELSCO
set "UIscooter=    " & set "scooter="
set "UIchip=        " & set "chip="
call :MIDUHEAD
@echo  Select Scooter model
@echo.
@echo  1 = Mi 1s
@echo  2 = Mi Pro2
@echo  3 = Mi 3
@echo  4 = Mi m365
@echo  5 = Mi Pro
@echo.

choice /c 12345b /n /m "Press [1],[2],[3],[4],[5] or [b] for back"
if "%ERRORLEVEL%" == "1" set "UIscooter=1s  " & set "scooter=1s" & set "bootFile=files\BLE\Bootloader\Bootloader_1s_Pro2_Mi3.bin"
if "%ERRORLEVEL%" == "2" set "UIscooter=Pro2" & set "scooter=Pro2" & set "bootFile=files\BLE\Bootloader\Bootloader_1s_Pro2_Mi3.bin"
if "%ERRORLEVEL%" == "3" set "UIscooter=Mi3 " & set "scooter=Mi3" & set "bootFile=files\BLE\Bootloader\Bootloader_1s_Pro2_Mi3.bin"
if "%ERRORLEVEL%" == "4" (
	if "%action%" == "Downgrade  " ( 
	@echo.
	@echo for m365 choose "Write Flash" or "Dump Flash"
	set "scooter=-   "
	pause
	goto :MIDUSELACT
	) else (
		set "UIscooter=m365" & set "scooter=m365" & set "bootFile=files\BLE\Bootloader\Bootloader_m365_Pro.hex"
	)
)


if "%ERRORLEVEL%" == "5" (	
	if "%action%" == "Downgrade  " ( 
	@echo.
	@echo for Pro choose "Write Flash" or "Dump Flash"
	set "scooter=-   "
	pause
	goto :MIDUSELACT
	) else (
		set "UIscooter=Pro " & set "scooter=Pro" & set "bootFile=files\BLE\Bootloader\Bootloader_m365_Pro.hex"
	)
)

if "%ERRORLEVEL%" == "6" goto :MIDUSELACT
if "%ERRORLEVEL%" == "255" @echo ERROR & pause & goto :MIDUSELSCO

REM -------------------------------------------------------

:MIDUSELCHI
set "UIchip=        " & set "chip="
call :MIDUHEAD
@echo  Select Microcontroller
@echo.
if "%device%" == "Dashboard " (
	@echo  1 = NRF51822QFAC ^(32kb RAM^)
	@echo  2 = NRF51802QFAA ^(16kb RAM^)
	@echo.
)
if "%device%" == "Controller" (
	@echo  1 = STM32F102
	@echo  2 = GD32E103CBT6
	@echo.
)

choice /c 12b /n /m "Press [1],[2] or [b] for back"
if "%ERRORLEVEL%" == "1" (
	if "%device%" == "Dashboard " (
		set "UIchip=N51822x " & set "chip=N51822x"
	)
	if "%device%" == "Controller" set "UIchip=STM32F1x" & set "chip=STM32F1x"
)

if "%ERRORLEVEL%" == "2" (
	if "%device%" == "Dashboard " (
		set "UIchip=N51802x " & set "chip=N51802x"
		if not exist "files\BLE\App\!chip!\%scooter%\App.bin" (
			call :MIDUHEAD
			@echo no firmware file found
			@echo N51802x chip ^(clone Dashboard^) requires a modified BLE firmware^^!
			@echo.
			@echo put modified BLE firmware file here^:
			@echo.
			@echo   - \MiDu-Flasher\Resource\files\BLE\App\!chip!\%scooter%\App.bin -
			@echo.
			pause
		)
		if not exist "files\BLE\App\!chip!\%scooter%\App.bin" (
			@echo.
			@echo no firmware file found
			@echo select chip again
			@echo.
			pause
			goto :MIDUSELCHI
		)

		if not exist "files\BLE\Bootloader\Bootloader_m365_Pro.hex" (
			@echo.
			@echo No m365^/Pro Bootloader file found
			@echo Downloading Bootloader from^:
			@echo.
			@echo https://files.scooterhacking.org/firmware/m365/BLE/blebootloader.hex
			@echo to^:
			@echo "files\BLE\Bootloader\Bootloader_m365_Pro.hex"
			pause
			call :MIDUDOWN "https://files.scooterhacking.org/firmware/m365/BLE/blebootloader.hex" "files\BLE\Bootloader\Bootloader_m365_Pro.hex"
			if not exist "files\BLE\Bootloader\Bootloader_m365_Pro.hex" (
				@echo.
				%sfk% tell [red]Error^^![def] could not download file
				@echo.
				pause
				goto :MIDUSELCHI
			)
		@echo.
		@echo Download successful
		@echo Thank^'s to scooterhacking.org ^<3
		pause
		)
		if not exist "files\BLE\Bootloader\Bootloader_1s_Pro2.bin" (
			@echo.
			@echo No 1s^/Pro2 Bootloader file found
			@echo Downloading Bootloader from^:
			@echo.
			@echo https://github.com/CamiAlfa/stlink_m365_BLE/raw/master/flashing/bootldr.bin
			@echo to^:
			@echo "files\BLE\Bootloader\Bootloader_1s_Pro2.bin"
			pause
			call :MIDUDOWN "https://github.com/CamiAlfa/stlink_m365_BLE/blob/master/flashing/bootldr.bin?raw=true" "files\BLE\Bootloader\Bootloader_1s_Pro2.bin"
			if not exist "files\BLE\Bootloader\Bootloader_1s_Pro2.bin" (
				@echo.
				%sfk% tell [red]Error^^![def] could not download file
				@echo.
				pause
				goto :MIDUSELCHI
			)
		@echo.
		@echo Download successful
		@echo Thank^'s to CamiAlfa ^<3
		pause
		)

	)
	if "%device%" == "Controller" set "UIchip=GD32E1x " & set "chip=GD32E1x"
)

if "%ERRORLEVEL%" == "3" goto :MIDUSELSCO	
if "%ERRORLEVEL%" == "255" @echo ERROR & pause & goto :MIDUSELCHI


REM --------------------------------------------------------------------------------------------------------------
REM --------------------------------------------------------------------------------------------------------------


:MIDUMAIN
call :MIDUHEAD
set "connected=false"
set "writing=false"
set /a "errors=0"
set /a "Aspeed=1000"


if "%chip%" == "N51822x" set "OCDtrgt=target/nrf51_S%Aspeed%.cfg"
if "%chip%" == "N51802x" set "OCDtrgt=target/nrf51_S%Aspeed%.cfg"
if "%chip%" == "STM32F1x" set "OCDtrgt=target/stm32f1x_S%Aspeed%.cfg"
if "%chip%" == "GD32E1x" set "OCDtrgt=target/GD32E1x_S%Aspeed%.cfg"


call :MIDUMYDT
@echo MIDUMAIN %mydate%_%mytime% device=%device% action=%action% scooter=%scooter% chip=%chip% >>MiDu.log
@echo MIDUMAIN working dir=%home% >>MiDu.log

REM ------------------

if "%action%" == "Downgrade  " (


	if "%OCDtrgt%" == "target/nrf51_S%Aspeed%.cfg" (
	
		if not exist "files\BLE\App\%chip%\%scooter%\App.bin" (
			
			if "%scooter%" == "1s" (
				set "appURL=https://files.scooterhacking.org/firmware/1s/BLE/BLE134.bin"
				set "appref=ScooterHacking.org"
				set "appmd5=35c96f1d83d97dc4bb842afcf030d8fe"
			)
			if "%scooter%" == "Pro2" (
				set "appURL=https://files.scooterhacking.org/firmware/pro2/BLE/BLE134.bin"
				set "appref=ScooterHacking.org"
				set "appmd5=b3c9023a0c7d89fbad0bf3f0dcc3cc0f"
			)
			if "%scooter%" == "Mi3" (
				set "appURL=https://files.scooterhacking.org/firmware/mi3/BLE/BLE152.bin"
				set "appref=ScooterHacking.org"
				set "appmd5=9650da1e091b8c438aea094c25648085"
			)
			if "%scooter%" == "m365" (
				set "appURL=https://files.scooterhacking.org/firmware/m365/BLE/BLE129.bin"
				set "appref=ScooterHacking.org"
				set "appmd5=f5aade9096ac0a2c99dae79a4849aa98"
			)
			if "%scooter%" == "Pro" (
				set "appURL=https://files.scooterhacking.org/firmware/pro/BLE/BLE122.bin"
				set "appref=ScooterHacking.org"
				set "appmd5=e8880676338e0a94cb8fb5f65b629d61"
			)
				
			@echo No BLE firmware file found
			@echo Downloading BLE firmware from^:
			@echo.
			@echo !appURL!
				@echo to^:
				@echo "files\BLE\App\%chip%\%scooter%\App.bin"
				@echo.
				pause
				call :MIDUDOWN "!appURL!" "files\BLE\App\%chip%\%scooter%\App.bin"
				if not exist "files\BLE\App\%chip%\%scooter%\App.bin" (
					@echo.
					%sfk% tell [red]Error^^![def] could not download file
					@echo.
					pause
					goto :MIDUSELCHI
				)
				@echo verifying md5sum
				for /f %%m in ('%sfk% md5 files\BLE\App\%chip%\%scooter%\App.bin') do if not ["%%m"] == ["!appmd5!"] (
					@echo.
					%sfk% tell [red]Error^^![def] download does not match expected md5sum
					@echo.
					if exist "files\BLE\App\%chip%\%scooter%\App.bin" del "files\BLE\App\%chip%\%scooter%\App.bin"
					pause
					goto :MIDUSELCHI
				)
				%sfk% tell [green]md5sum verified
				@echo.
				@echo Download successful
				@echo Thank^'s to !appref! ^<3
				@echo.
				pause
		REM end if not exist App	
		)

		if not exist "%bootFile%" (
			
			if "%scooter%" == "1s" (
				set "bootURL=https://github.com/CamiAlfa/stlink_m365_BLE/raw/master/flashing/bootldr.bin"
				set "bootref=CamiAlfa"
				set "bootmd5=a4b799104eca2744bb4147b534ff0533"
			)
			if "%scooter%" == "Pro2" (
				set "bootURL=https://github.com/CamiAlfa/stlink_m365_BLE/raw/master/flashing/bootldr.bin"
				set "bootref=CamiAlfa"
				set "bootmd5=a4b799104eca2744bb4147b534ff0533"
			)
			if "%scooter%" == "Mi3" (
				set "bootURL=https://github.com/CamiAlfa/stlink_m365_BLE/raw/master/flashing/bootldr.bin"
				set "bootref=CamiAlfa"
				set "bootmd5=a4b799104eca2744bb4147b534ff0533"
			)
			if "%scooter%" == "m365" (
				set "bootURL=https://files.scooterhacking.org/firmware/m365/BLE/blebootloader.hex"
				set "bootref=ScooterHacking.org"
				set "bootmd5=bb186e84b057a50f5f208c07624602f3"
			)
			if "%scooter%" == "Pro" (
				set "bootURL=https://files.scooterhacking.org/firmware/m365/BLE/blebootloader.hex"
				set "bootref=ScooterHacking.org"
				set "bootmd5=bb186e84b057a50f5f208c07624602f3"
			)
			
			@echo.
			@echo No Bootloader found
			@echo Downloading Bootloader from^:
			@echo.
			@echo !bootURL!
				@echo to^:
				@echo "%bootFile%"
				@echo.
				pause
				call :MIDUDOWN "!bootURL!" "%bootFile%"
				if not exist "%bootFile%" (
					@echo.
					%sfk% tell [red]Error^^![def] could not download file
					@echo.
					pause
					goto :MIDUSELCHI
				)
				@echo verifying md5sum
				for /f %%m in ('%sfk% md5 %bootFile%') do if not ["%%m"] == ["!bootmd5!"] (
					@echo.
					%sfk% tell [red]Error^^![def] download does not match expected md5sum
					@echo.
					if exist "%bootFile%" del "%bootFile%"
					pause
					goto :MIDUSELCHI
				)
				%sfk% tell [green] md5sum verified
				@echo.
				@echo Download successful
				@echo Thank^'s to !bootref! ^<3
				@echo.
				pause
		REM end if not exist Bootloader	
		)	
	
		call :MIDUHEAD
		@echo.
		if "%scooter%" == "Mi3" (
			set "spoofto=55
		) else (
			set "spoofto=57
		)
		@echo spoof new BLE to 1!spoofto! ^? ^(recommended^)
		choice /c yn /n /m "Press [y] to spoof and [n] to leave BLE untouched"
		if "!ERRORLEVEL!" == "1" (
			if exist "files\BLE\App\%chip%\%scooter%\AppSpoofed.bin" del "files\BLE\App\%chip%\%scooter%\AppSpoofed.bin" >NUL
			call :MIDUSPOOF
			pause
		)
		call :MIDUHEAD
		@echo Press any key, to start the initial downgrade countdown 
		@echo If not done already, connect ST-Link adapter to PC now
		@echo.
		pause
		@echo.
		@echo Connect wires to Dashboard now, you have 30 seconds to do so...
		set "Msleep=30"
		call :MIDUSLEEP
		
		call :MIDUHEAD
		call :MIDUMYDT
		set "OCDiofle=..\\0x10001000_nrf51_UICR_%mydate%_%mytime%.bin"
		set "OCDsofst=0x10001000"
		set "OCDleng=0x400"
		@echo establishing first connection
		call :OCDINIT
		%sfk% tell [blue]Connected
		@echo dumping UICR now
		call :OCDDUMP
		%sfk% tell [green]Done
		set "OCDiofle=..\\0x10000000_nrf51_FICR_%mydate%_%mytime%.bin"
		set "OCDsofst=0x10000000"
		set "OCDleng=0x400"
		@echo dumping FICR now
		call :OCDINIT
		call :OCDDUMP
		%sfk% tell [green]Done
		for /f %%h in ('%sfk% hexdump -nofile -pure -offlen 0x00000004 0x00000004 ..\\"0x10001000_nrf51_UICR_%mydate%_%mytime%.bin"') do set "CRP=%%h" >NUL
		if not "!CRP!" == "FFFFFFFF" (
			set "EXPofst=0x0003B800"
			set "EXPofle=0x100"
			@echo Code readout protection has been set
			@echo Dumping app_config ^(blt-id^) via exploit now, be patient ^;^)
			call :OCDINIT
			call :OCDEXPDUMP
			move "EXP_DUMP.bin" "..\\0x0003B800_nrf51_app_config.bin" >NUL
			%sfk% tell [green]Done
		) else (
		set "OCDiofle=..\\0x0003B800_nrf51_app_config.bin"
		set "OCDsofst=0x0003B800"
		set "OCDleng=0x100"
		@echo Dumping app_config ^(your blt-id^) now
		call :OCDINIT
		call :OCDDUMP
		%sfk% tell [green]Done
		)
		cd..
		for /f %%h in ('Resource\%sfk% hexdump -nofile -flat -offlen 0x00000083 0x00000013 0x0003B800_nrf51_app_config.bin') do set "bltid=%%h" >NUL
		cd Resource
		if not "!bltid:~0,3!" == "blt" (
		start bin\PlaySound.exe files\Audio\error.wav
		@echo.
		%sfk% tell [red]ERROR no blt-id found
		@echo Aborting downgrade now
		@echo If you are feeling adventurous, try the "write flash" function
		@echo.
		pause
		exit
		)
		@echo.
		@echo Your blt-id ^= !bltid!
		@echo.
		move "..\\0x0003B800_nrf51_app_config.bin" "..\\0x0003B800_nrf51_app_config_!bltid!.bin" >NUL

		@echo performing N51x mass erase now
		call :OCDINIT
		call :OCDERASE
		%sfk% tell [green]Done
		
		set "OCDiofle=files/BLE/Softdevice/s130_nrf51_2.0.1_softdevice.hex"
		set "OCDsofst=" REM 0x00000000
		@echo writing 1s^/Pro2^/Mi3 softdevice s130 now
		call :OCDINIT
		call :OCDWRITE
		%sfk% tell [green]Done
		
		if "!spoofed!" == "true" (
			set "OCDiofle=files/BLE/App/%chip%/%scooter%/AppSpoofed.bin"
			@echo writing spoofed %scooter% BLE1!spoofto! now
		) else (
		set "OCDiofle=files/BLE/App/%chip%/%scooter%/App.bin"
		@echo writing %scooter% App aka BLE now
		)
		set "OCDsofst=0x0001B000"
		call :OCDINIT
		call :OCDWRITE
		%sfk% tell [green]Done
		
		set "OCDiofle=..\\0x0003B800_nrf51_app_config_!bltid!.bin"
		set "OCDsofst=0x0003B800"
		@echo writing %scooter% app_config ^(your blt-id^) now
		call :OCDINIT
		call :OCDWRITE
		%sfk% tell [green]Done
				
		set "OCDiofle=files/BLE/Bootloader/Bootloader_1s_Pro2_Mi3.bin"
		set "OCDsofst=0x0003D000"
		@echo writing 1s^/Pro2^/Mi3 bootloader now
		call :OCDINIT
		call :OCDWRITE
		%sfk% tell [green]Done
				
		set "OCDiofle=files/BLE/Bootloader/UICR_1s_Pro2_Mi3.hex"
		set "OCDsofst="
		@echo writing 1s^/Pro2^/Mi3 UICR now
		call :OCDINIT
		call :OCDWRITE
		%sfk% tell [green]Done


	)
	
)

REM ------------------

if "%action%" == "Dump Flash " (


	if "%OCDtrgt%" == "target/nrf51_S%Aspeed%.cfg" (
		set "OCDiofle=..\\0x10001000_nrf51_UICR_%mydate%_%mytime%.bin"
		set "OCDsofst=0x10001000"
		set "OCDleng=0x400"
		@echo dumping UICR now
		call :OCDINIT
		call :OCDDUMP
		%sfk% tell [green]Done
		set "OCDiofle=..\\0x10000000_nrf51_FICR_%mydate%_%mytime%.bin"
		set "OCDsofst=0x10000000"
		set "OCDleng=0x400"
		@echo dumping FICR now
		call :OCDINIT
		call :OCDDUMP
		%sfk% tell [green]Done

		for /f %%h in ('%sfk% hexdump -nofile -pure -offlen 0x00000004 0x00000004 ..\\"0x10001000_nrf51_UICR_%mydate%_%mytime%.bin"') do set "CRP=%%h" >NUL
		if not "!CRP!" == "FFFFFFFF" (
			@echo code readout protection has been set, dump flash via debug exploit^?
			@echo dumping via exploit at adapter speed 1k will take about 1^:20h 
			choice /c ye /n /m "Press [y] to use exploit, or [e] to exit now"
			if "!ERRORLEVEL!" == "1" (
				set "EXPofst=0x00000000"
				set "EXPofle=0x40000"
				@echo dumping CODE via exploit now, be patient ^;^)
				call :OCDINIT
				call :OCDEXPDUMP
				move "EXP_DUMP.bin" "..\\0x00000000_nrf51_CODE_%mydate%_%mytime%.bin" >NUL
				%sfk% tell [green]Done
			)
			if "!ERRORLEVEL!" == "2" (
				goto :MIDUEND
			)
			if "!ERRORLEVEL!" == "255" goto :MIDUEND
		
	) else (
	set "OCDiofle=..\\0x00000000_nrf51_CODE_%mydate%_%mytime%.bin"
	set "OCDsofst=0x00000000"
	set "OCDleng=0x40000"
	@echo dumping CODE now
	call :OCDINIT
	call :OCDDUMP
	%sfk% tell [green]Done
		)
	)

)

REM ------------------

if "%action%" == "Write Flash" (

	
	if "%OCDtrgt%" == "target/nrf51_S%Aspeed%.cfg" (
		
	
		if "%chip%" == "N51822x" (
		
			if not exist "files\BLE\App\%chip%\%scooter%\App.bin" (
			
				if "%scooter%" == "1s" (
					set "appURL=https://files.scooterhacking.org/firmware/1s/BLE/BLE134.bin"
					set "appref=ScooterHacking.org"
					set "appmd5=35c96f1d83d97dc4bb842afcf030d8fe"
				)
				if "%scooter%" == "Pro2" (
					set "appURL=https://files.scooterhacking.org/firmware/pro2/BLE/BLE134.bin"
					set "appref=ScooterHacking.org"
					set "appmd5=b3c9023a0c7d89fbad0bf3f0dcc3cc0f"
				)
				if "%scooter%" == "Mi3" (
					set "appURL=https://files.scooterhacking.org/firmware/mi3/BLE/BLE152.bin"
					set "appref=ScooterHacking.org"
					set "appmd5=9650da1e091b8c438aea094c25648085"
				)
				if "%scooter%" == "m365" (
					set "appURL=https://files.scooterhacking.org/firmware/m365/BLE/BLE129.bin"
					set "appref=ScooterHacking.org"
					set "appmd5=f5aade9096ac0a2c99dae79a4849aa98"
				)
				if "%scooter%" == "Pro" (
					set "appURL=https://files.scooterhacking.org/firmware/pro/BLE/BLE122.bin"
					set "appref=ScooterHacking.org"
					set "appmd5=e8880676338e0a94cb8fb5f65b629d61"
				)
				
				@echo No BLE firmware file found
				@echo Downloading BLE firmware from^:
				@echo.
				@echo !appURL!
				@echo to^:
				@echo "files\BLE\App\%chip%\%scooter%\App.bin"
				@echo.
				pause
				call :MIDUDOWN "!appURL!" "files\BLE\App\%chip%\%scooter%\App.bin"
				if not exist "files\BLE\App\%chip%\%scooter%\App.bin" (
					@echo.
					%sfk% tell [red]Error^^![def] could not download file
					@echo.
					pause
					goto :MIDUSELCHI
				)
				@echo verifying md5sum
				for /f %%m in ('%sfk% md5 files\BLE\App\%chip%\%scooter%\App.bin') do if not ["%%m"] == ["!appmd5!"] (
					@echo.
					%sfk% tell [red]Error^^![def] download does not match expected md5sum
					@echo.
					if exist "files\BLE\App\%chip%\%scooter%\App.bin" del "files\BLE\App\%chip%\%scooter%\App.bin"
					pause
					goto :MIDUSELCHI
				)
				@echo md5sum verified
				@echo.
				@echo Download successful
				@echo Thank^'s to !appref! ^<3
				@echo.
				pause
			REM end if not exist App	
			)

			if not exist "%bootFile%" (
			
				if "%scooter%" == "1s" (
					set "bootURL=https://github.com/CamiAlfa/stlink_m365_BLE/raw/master/flashing/bootldr.bin"
					set "bootref=CamiAlfa"
					set "bootmd5=a4b799104eca2744bb4147b534ff0533"
				)
				if "%scooter%" == "Pro2" (
					set "bootURL=https://github.com/CamiAlfa/stlink_m365_BLE/raw/master/flashing/bootldr.bin"
					set "bootref=CamiAlfa"
					set "bootmd5=a4b799104eca2744bb4147b534ff0533"
				)
				if "%scooter%" == "Mi3" (
					set "bootURL=https://github.com/CamiAlfa/stlink_m365_BLE/raw/master/flashing/bootldr.bin"
					set "bootref=CamiAlfa"
					set "bootmd5=a4b799104eca2744bb4147b534ff0533"
				)
				if "%scooter%" == "m365" (
					set "bootURL=https://files.scooterhacking.org/firmware/m365/BLE/blebootloader.hex"
					set "bootref=ScooterHacking.org"
					set "bootmd5=bb186e84b057a50f5f208c07624602f3"
				)
				if "%scooter%" == "Pro" (
					set "bootURL=https://files.scooterhacking.org/firmware/m365/BLE/blebootloader.hex"
					set "bootref=ScooterHacking.org"
					set "bootmd5=bb186e84b057a50f5f208c07624602f3"
				)
			
				@echo.
				@echo No Bootloader found
				@echo Downloading Bootloader from^:
				@echo.
				@echo !bootURL!
				@echo to^:
				@echo "%bootFile%"
				@echo.
				pause
				call :MIDUDOWN "!bootURL!" "%bootFile%"
				if not exist "%bootFile%" (
					@echo.
					%sfk% tell [red]Error^^![def] could not download file
					@echo.
					pause
					goto :MIDUSELCHI
				)
				@echo verifying md5sum
				for /f %%m in ('%sfk% md5 %bootFile%') do if not ["%%m"] == ["!bootmd5!"] (
					@echo.
					%sfk% tell [red]Error^^![def] download does not match expected md5sum
					@echo.
					if exist "%bootFile%" del "%bootFile%"
					pause
					goto :MIDUSELCHI
				)
				@echo md5sum verified
				@echo.
				@echo Download successful
				@echo Thank^'s to !bootref! ^<3
				@echo.
				pause
			REM end if not exist Bootloader	
			)	
		REM end if chip
		) 
	
		call :MIDUHEAD
		@echo.
		@echo performing N51x mass erase now
		call :OCDINIT
		call :OCDERASE
		%sfk% tell [green]Done
		
		if "%scooter%" == "1s" (
			set "OCDiofle=files/BLE/Softdevice/s130_nrf51_2.0.1_softdevice.hex"
			set "OCDsofst=" REM 0x00000000
			@echo writing 1s^/Pro2 softdevice s130 now
			call :OCDINIT
			call :OCDWRITE
			%sfk% tell [green]Done
			
			set "OCDiofle=files/BLE/App/%chip%/%scooter%/App.bin"
			set "OCDsofst=0x0001B000"
			@echo writing %scooter% App aka BLE now
			call :OCDINIT
			call :OCDWRITE
			%sfk% tell [green]Done
			
			set "OCDiofle=files/BLE/Bootloader/Bootloader_1s_Pro2_Mi3.bin"
			set "OCDsofst=0x0003D000"
			@echo writing 1s^/Pro2 bootloader now
			call :OCDINIT
			call :OCDWRITE
			%sfk% tell [green]Done
			
			set "OCDiofle=files/BLE/Bootloader/UICR_1s_Pro2_Mi3.hex"
			set "OCDsofst="
			@echo writing 1s^/Pro2 UICR now
			call :OCDINIT
			call :OCDWRITE
			%sfk% tell [green]Done
		)
		REM ------------------
		if "%scooter%" == "Pro2" (
			set "OCDiofle=files/BLE/Softdevice/s130_nrf51_2.0.1_softdevice.hex"
			set "OCDsofst=" REM 0x00000000
			@echo writing 1s^/Pro2 softdevice s130 now
			call :OCDINIT
			call :OCDWRITE
			%sfk% tell [green]Done
			
			set "OCDiofle=files/BLE/App/%chip%/%scooter%/App.bin"
			set "OCDsofst=0x0001B000"
			@echo writing %scooter% App aka BLE now
			call :OCDINIT
			call :OCDWRITE
			%sfk% tell [green]Done	
			
			set "OCDiofle=files/BLE/Bootloader/Bootloader_1s_Pro2_Mi3.bin"
			set "OCDsofst=0x0003D000"
			@echo writing 1s^/Pro2 bootloader now
			call :OCDINIT
			call :OCDWRITE
			%sfk% tell [green]Done
			
			set "OCDiofle=files/BLE/Bootloader/UICR_1s_Pro2_Mi3.hex"
			set "OCDsofst="
			@echo writing 1s^/Pro2 UICR now
			call :OCDINIT
			call :OCDWRITE
			%sfk% tell [green]Done
		)
		REM ------------------
		if "%scooter%" == "Mi3" (
			set "OCDiofle=files/BLE/Softdevice/s130_nrf51_2.0.1_softdevice.hex"
			set "OCDsofst=" REM 0x00000000
			@echo writing 1s^/Pro2^/Mi3 softdevice s130 now
			call :OCDINIT
			call :OCDWRITE
			%sfk% tell [green]Done
			
			set "OCDiofle=files/BLE/App/%chip%/%scooter%/App.bin"
			set "OCDsofst=0x0001B000"
			@echo writing %scooter% App aka BLE now
			call :OCDINIT
			call :OCDWRITE
			%sfk% tell [green]Done
			
			set "OCDiofle=files/BLE/Bootloader/Bootloader_1s_Pro2_Mi3.bin"
			set "OCDsofst=0x0003D000"
			@echo writing 1s^/Pro2^/Mi3 bootloader now
			call :OCDINIT
			call :OCDWRITE
			%sfk% tell [green]Done
			
			set "OCDiofle=files/BLE/Bootloader/UICR_1s_Pro2_Mi3.hex"
			set "OCDsofst="
			@echo writing 1s^/Pro2^/Mi3 UICR now
			call :OCDINIT
			call :OCDWRITE
			%sfk% tell [green]Done
		)
		REM ------------------
		if "%scooter%" == "m365" (
			set "OCDiofle=files/BLE/Softdevice/s110_nrf51_8.0.0_softdevice.hex"
			set "OCDsofst=" REM 0x00000000
			@echo writing m365^/Pro softdevice s110 now
			call :OCDINIT
			call :OCDWRITE
			%sfk% tell [green]Done
				
			set "OCDiofle=files/BLE/App/%chip%/%scooter%/App.bin"
			set "OCDsofst=0x00018000"
			@echo writing %scooter% App aka BLE now
			call :OCDINIT
			call :OCDWRITE
			%sfk% tell [green]Done
			
			set "OCDiofle=files/BLE/Bootloader/Bootloader_m365_Pro.hex"
			set "OCDsofst=" REM 0x0003C000
			@echo writing m365^/Pro bootloader and UICR now
			call :OCDINIT
			call :OCDWRITE
			%sfk% tell [green]Done
		)
		REM ------------------
		if "%scooter%" == "Pro" (
			set "OCDiofle=files/BLE/Softdevice/s110_nrf51_8.0.0_softdevice.hex"
			set "OCDsofst=" REM 0x00000000
			@echo writing m365^/Pro softdevice s110 now
			call :OCDINIT
			call :OCDWRITE
			%sfk% tell [green]Done
			
			set "OCDiofle=files/BLE/App/%chip%/%scooter%/App.bin"
			set "OCDsofst=0x00018000"
			@echo writing %scooter% App aka BLE now
			call :OCDINIT
			call :OCDWRITE
			%sfk% tell [green]Done
			
			set "OCDiofle=files/BLE/Bootloader/Bootloader_m365_Pro.hex"
			set "OCDsofst=" REM 0x0003C000
			@echo writing m365^/Pro bootloader and UICR now
			call :OCDINIT
			call :OCDWRITE
			%sfk% tell [green]Done
		)
		
		
		
		
		
		
		
	
	REM enf if target
	)




)

REM ------------------


call :OCDRESET
@echo reset command has been send
@echo if there was no beep, there might be something wrong with the firmware
@echo all done, exiting now
goto :MIDUEND
pause
exit

REM ------------------------MiDu---------------------------

:MIDUSLEEP
if not "%Msleep%" == "0" (
@echo|set /p="."
choice /d n /t 1 >NUL
set /a Msleep-=1
goto :MIDUSLEEP
)
goto :eof

REM ------------------------MiDu---------------------------

:MIDUSPOOF
call :MIDUMYDT
@echo %0 %mydate%_%mytime% >>MiDu.log

@echo searching for version
@echo.
for /f %%f in ('%sfk% xhexfind "files\BLE\App\%chip%\%scooter%\App.bin" -firsthit "/[1 byte]\x21\x01\x71\x01/" +filt -+0x "-line=1" -replace "_files\BLE\App\%chip%\%scooter%\App.bin : hit at offset __" -replace "_ len 5__"') do @set veroffset=%%f
if "%veroffset%" == "" (
	for /f %%f in ('%sfk% xhexfind "files\BLE\App\%chip%\%scooter%\App.bin" -firsthit "/[1 byte]\x21\x01\x71\x00/" +filt -+0x "-line=1" -replace "_files\BLE\App\%chip%\%scooter%\App.bin : hit at offset __" -replace "_ len 5__"') do @set veroffset=%%f	
)
if "%veroffset%" == "" (
	%sfk% tell [red]Error^^![def] can not find version to spoof
	@echo %0 %mydate%_%mytime% ERROR^^! can not find version to spoof in "files\BLE\App\%chip%\%scooter%\App.bin" >>MiDu.log
	set "spoofed=false"
) else (
copy "files\BLE\App\%chip%\%scooter%\App.bin" "files\BLE\App\%chip%\%scooter%\AppSpoofed.bin" >NUL
%sfk% setbytes "files\BLE\App\%chip%\%scooter%\AppSpoofed.bin" %veroffset% 0x%spoofto%21017101 -yes >NUL
set "spoofed=true"
%sfk% tell [green]Done[def] spoofed successfully to 1%spoofto%
@echo %0 %mydate%_%mytime% done, spoofed successfully "files\BLE\App\%chip%\%scooter%\AppSpoofed.bin" to 1%spoofto% at offset=%veroffset% >>MiDu.log
)

goto :eof
pause
exit

REM ------------------------MiDu---------------------------

:MIDUDOWN
call :MIDUMYDT
@echo %0 %mydate%_%mytime% %1 %2 >>MiDu.log
bin\curl.exe -s -L %1 -o %2
goto :eof
pause
exit

REM ------------------------MiDu---------------------------

:MIDUMYDT
set mydate=%date:~-10,2%-%date:~-7,2%-%date:~-4%
if "%time:~-11,1%" == " " (
		set mytime=0%time:~1,1%-%time:~-8,2%-%time:~-5,2%
	) else (
		set mytime=%time:~-11,2%-%time:~-8,2%-%time:~-5,2%
		)
	)
goto :eof
pause
exit

REM ------------------------MiDu---------------------------

:MIDUEND
bin\PlaySound.exe files\Audio\done.wav
call :MIDUMYDT
@echo %0 %mydate%_%mytime% >>MiDu.log

pause
exit
pause

REM ------------------------MiDu---------------------------

:MIDUERROR
set "connected=false" & start bin\PlaySound.exe files\Audio\error.wav
set "writing=false"
set /a errors+=1
set /a "errorl1=5"
set /a "errorl2=20"
call :MIDUMYDT

if "%1" == ":OCDRESET" (
	%sfk% tell [red]Error^^![def] there might be something wrong with the device firmware,
	@echo         either no connection, or no reset possible
	@echo         current adapter speed=%Aspeed%, there have been %errors% errors occured 
	@echo         retry in 5 Seconds
	@echo ERROR %1 %mydate%_%mytime% no Connection, errors=%errors% speed=%Aspeed% >>MiDu.log
	@echo. >>MiDu.log
) else (
	%sfk% tell [red]Error^^![def] No connection, adapter speed=%Aspeed% retry in 5 Seconds
	@echo ERROR %1 %mydate%_%mytime% no Connection, errors=%errors% speed=%Aspeed% >>MiDu.log
	@echo. >>MiDu.log
)

if "%Aspeed%" == "1000" (
	if "%errors%" == "%errorl1%" (
		@echo there have been %errors% errors occured, setting adapter speed down to 400 now
		@set "Aspeed=400"
		@set "OCDtrgt=target/nrf51_S!Aspeed!.cfg"
	)
)
if "%Aspeed%" == "400" (
	if "%errors%" == "%errorl2%" (
		@echo there have been %errors% errors occured, setting adapter speed down to 100 now
		set "Aspeed=100"
		set "OCDtrgt=target/nrf51_S!Aspeed!.cfg"
	)
)

choice /d n /t 5 >NUL
goto :eof
pause
exit

REM ------------------------OCD----------------------------

:OCDINIT
call :MIDUMYDT
@echo OCDINIT %mydate%_%mytime% >>MiDu.log
bin\OpenOCD\bin\openocd.exe -f "interface/stlink.cfg" -f %OCDtrgt% -c "init" -c "reset halt" -c "exit" 2>&0 2>>MiDu.log
if errorlevel 1 (
	call :MIDUERROR %0
	goto :OCDINIT
)
if "!connected!" == "false" bin\PlaySound.exe files\Audio\connected.wav
set "connected=true"
goto :eof
pause
exit

REM ------------------------OCD----------------------------

:OCDRESET
call :MIDUMYDT
@echo OCDRESET %mydate%_%mytime% >>MiDu.log
bin\OpenOCD\bin\openocd.exe -f "interface/stlink.cfg" -f %OCDtrgt% -c "init" -c "reset" -c "exit" 2>&0 2>>MiDu.log
if errorlevel 1 (
	call :MIDUERROR %0
	goto :OCDRESET
)
goto :eof
pause
exit

REM ------------------------OCD----------------------------

:OCDERASE
call :MIDUMYDT
@echo OCDERASE %mydate%_%mytime% >>MiDu.log
bin\OpenOCD\bin\openocd.exe -f "interface/stlink.cfg" -f %OCDtrgt% -c "init" -c "nrf51 mass_erase" -c "exit" 2>&0 2>>MiDu.log
if errorlevel 1 (
	call :MIDUERROR %0
	call :OCDINIT
	goto :OCDRESET
)
goto :eof
pause
exit

REM ------------------------OCD----------------------------

:OCDDUMP
call :MIDUMYDT
@echo OCDDUMP %mydate%_%mytime% >>MiDu.log
bin\OpenOCD\bin\openocd.exe -f "interface/stlink.cfg" -f %OCDtrgt% -c "init" -c "dump_image %OCDiofle% %OCDsofst% %OCDleng%" -c "exit" 2>&0 2>>MiDu.log
if errorlevel 1 (
	call :MIDUERROR %0
	call :OCDINIT
	goto :OCDDUMP
)
goto :eof
pause
exit

REM ------------------------OCD----------------------------

:OCDWRITE
REM if "!writing!" == "false" start bin\PlaySound.exe files\Audio\writing.wav
call :MIDUMYDT
@echo OCDWRITE %mydate%_%mytime% >>MiDu.log
bin\OpenOCD\bin\openocd.exe -f "interface/stlink.cfg" -f %OCDtrgt% -c "init" -c "program %OCDiofle% %OCDsofst% verify" -c "exit" 2>&0 2>>MiDu.log
if errorlevel 1 (
	call :MIDUERROR %0
	call :OCDINIT
	goto :OCDWRITE
)

set "writing=true"
goto :eof
pause
exit

REM ------------------------OCD----------------------------

:OCDEXPDUMP
SET /a EXPofen=%EXPofst% + %EXPofle%
call :MIDUMYDT
@echo OCDEXPDUMP %mydate%_%mytime% >>MiDu.log
if exist "EXP_DUMP.hex" del "EXP_DUMP.hex"
if exist "EXP_DUMP.bin" del "EXP_DUMP.bin"

:OCDEXPDLOOP
bin\OpenOCD\bin\openocd.exe -d0 -f "interface/stlink.cfg" -f %OCDtrgt% -c "init" -c "reg r4 %EXPofst%" -c "step 0x6d4" -c "reg r4" -c "exit" 2>&1 | for /f %%f in ('%sfk% filt -+r4 "-line=11" -replace "_r4 (/32): __"') do @%sfk% num -hex -show hexle %%f +append EXP_DUMP.hex
if errorlevel 1 (
	call :MIDUERROR %0
	call :MIDUMYDT
	@echo ERROR %0 !mydate!_!mytime! no Connection, current Offset=%EXPofst% >>MiDu.log
	call :OCDINIT
	goto :OCDEXPDLOOP
)
set /a EXPofst+=4
if %EXPofst% GEQ %EXPofen% (
	%sfk% filter "EXP_DUMP.hex" +hextobin EXP_DUMP.bin >NUL
	goto :eof
)
goto :OCDEXPDLOOP
pause
exit


REM ------------------------MiDu---------------------------

:MIDUHEAD
cls
@echo  *************************************************************************
@echo  *                       ____________________________                    *
@echo  *                      ^/                           ^/^\                   *
@echo  *                     ^/       MiDu-Flasher        ^/ ^/^\                  *
@echo  *                    ^/  Mi Downgrade ^& Unbrick   ^/ ^/^\                   *
@echo  *                   ^/       ST-Link Utility     ^/ ^/^\                    *
@echo  *                  ^/___________________________^/ ^/^\                     *
@echo  *                  ^\___________________________^\^/^\                      *
@echo  *                   ^\ ^\ ^\ ^\ ^\ ^\ ^\ ^\ ^\ ^\ ^\ ^\ ^\ ^\ ^\                       *
@echo  *                                                                       *
@echo  *                      powered by OpenOCD                               *
@echo  *                      created by VooDooShamane                         *
@echo  *                      support Rollerplausch.com                        *
@echo  *                                                                v1.0.5 *
@echo  *************************************************************************
@echo  -------------------------------------------------------------------------
@echo  ^| Target=%device% ^| Action=%action% ^| Scooter=%UIscooter% ^| Chip=%UIchip% ^|
@echo  -------------------------------------------------------------------------
@echo.
goto :eof
pause
exit

REM ------------------------MiDu---------------------------