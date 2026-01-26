@echo off
chcp 949 > nul
setlocal enabledelayedexpansion

:: [1. 설정]
set "current_ver=1.2.2"
set "ver_url=https://raw.githubusercontent.com/YubiLemon/mc-zlong-cloud-server/main/version.txt"
:: GitHub 파일명을 zlong_server.bat으로 바꿨다고 가정하고 수정한 주소입니다.
set "download_url=https://raw.githubusercontent.com/YubiLemon/mc-zlong-cloud-server/main/zlong_server.bat"
set "webhook_url=https://discord.com/api/webhooks/1465304132624715950/KphKke96wiNvBgeF2180THVl744I7-Cyok-G2gjbI2Bg8eaO3KP6WQmX0x79PSeu4_Ov"

title zlong 서버 접속기 v%current_ver%

:: [2. 업데이트 확인]
echo [1/3] 업데이트 확인 중... (v%current_ver%)
for /f "usebackq tokens=*" %%v in (`powershell -Command "(Invoke-WebRequest -Uri '%ver_url%' -UseBasicParsing).Content.Trim()"`) do set "latest_ver=%%v"

if not "%current_ver%"=="%latest_ver%" (
    echo.
    echo [!] 새 버전 발견 (!latest_ver!). 다운로드 중...
    powershell -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri '%download_url%' -OutFile 'zlong_update_temp.bat' -UseBasicParsing"
    
    if exist "zlong_update_temp.bat" (
        echo [v] 업데이트 완료! 새 파일을 실행합니다.
        timeout /t 2 > nul
        start "" "zlong_update_temp.bat"
        (goto) 2>nul & del "%~nx0" & exit
    ) else (
        echo [!] 다운로드 실패. GitHub 파일 이름을 확인하세요.
        pause & exit
    )
)

:: [3. IP 전송]
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
echo   접속 확인됨: %username% (%client_ip%)
echo ==================================================
pause