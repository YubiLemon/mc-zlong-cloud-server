@echo off
chcp 949 > nul
setlocal enabledelayedexpansion

:: [1. 설정 영역]
set "current_ver=1.0.0"
set "ver_url=https://raw.githubusercontent.com/YubiLemon/mc-zlong-cloud-server/main/version.txt"
set "download_url=https://raw.githubusercontent.com/YubiLemon/mc-zlong-cloud-server/main/connect.bat"
set "webhook_url=https://discord.com/api/webhooks/1465304132624715950/KphKke96wiNvBgeF2180THVl744I7-Cyok-G2gjbI2Bg8eaO3KP6WQmX0x79PSeu4_Ov"

title zlong 서버 접속기 v%current_ver%

:: [2. 자동 업데이트]
echo [1/3] 업데이트 확인 중... (v%current_ver%)
for /f "usebackq tokens=*" %%v in (`powershell -Command "(Invoke-WebRequest -Uri '%ver_url%' -UseBasicParsing).Content.Trim()"`) do set "latest_ver=%%v"

if not "%current_ver%"=="%latest_ver%" (
    echo [!] 새 버전 발견 (!latest_ver!). 업데이트 중...
    powershell -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri '%download_url%' -OutFile 'connect_new.bat' -UseBasicParsing"
    
    if exist "connect_new.bat" (
        start "" "connect_new.bat"
        (goto) 2>nul & del "%~nx0" & exit
    )
)

:: [3. IP 전송 및 디스코드 알림]
echo [2/3] 접속 기록 전송 중...
for /f "usebackq tokens=*" %%a in (`powershell -Command "(Invoke-WebRequest -Uri 'https://api.ipify.org' -UseBasicParsing).Content"`) do set "client_ip=%%a"
powershell -Command "$msg = @{ content = ' **zlong 서버 접속**\n- 유저: %username%\n- IP: %client_ip%' }; Invoke-RestMethod -Uri '%webhook_url%' -Method Post -Body ($msg | ConvertTo-Json) -ContentType 'application/json' -ErrorAction SilentlyContinue"

:: [4. 터널 실행]
echo [3/3] 서버 연결 중...
start /b cloudflared access tcp --hostname mc.zlong.cloud --listener localhost:25565 > nul 2>&1
timeout /t 5 > nul

cls
echo ==================================================
echo   zlong 서버 연결 성공! (v%current_ver%)
echo ==================================================
echo   마인크래프트 실행 후 'localhost'로 접속하세요.
echo ==================================================
pause