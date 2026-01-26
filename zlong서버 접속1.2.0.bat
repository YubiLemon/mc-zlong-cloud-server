@echo off
chcp 949 > nul
setlocal enabledelayedexpansion

:: ==================================================
:: [1. 설정 영역]
:: ==================================================
set "current_ver=1.2.0"

:: GitHub Raw 주소
set "ver_url=https://raw.githubusercontent.com/YubiLemon/mc-zlong-cloud-server/main/version.txt"
set "download_url=https://raw.githubusercontent.com/YubiLemon/mc-zlong-cloud-server/main/zlong%%EC%%84%%9C%%EB%%B2%%94%%20%%EC%%A0%%91%%EC%%86%%9D1.2.0.bat"

:: 본인의 디스코드 웹후크 URL을 아래 따옴표 안에 넣으세요
set "webhook_url=https://discord.com/api/webhooks/..."

title zlong 서버 접속기 v%current_ver%

:: ==================================================
:: [2. 업데이트 확인 로직]
:: ==================================================
echo [1/3] 업데이트 확인 중...
for /f "usebackq tokens=*" %%v in (`powershell -Command "(Invoke-WebRequest -Uri '%ver_url%' -UseBasicParsing).Content.Trim()"`) do set "latest_ver=%%v"

if not "%current_ver%"=="%latest_ver%" (
    echo.
    echo --------------------------------------------------
    echo  새로운 버전이 발견되었습니다! (!latest_ver!)
    echo  업데이트를 진행합니다. 잠시만 기다려 주세요.
    echo --------------------------------------------------
    
    :: 한글 깨짐 방지를 위해 임시 영문 파일명으로 다운로드
    powershell -Command "Invoke-WebRequest -Uri '%download_url%' -OutFile 'zlong_update_temp.bat'"
    
    if exist "zlong_update_temp.bat" (
        echo.
        echo  [v] 다운로드 완료. 프로그램을 교체합니다.
        timeout /t 2 > nul
        start "" "zlong_update_temp.bat"
        (goto) 2>nul & del "%~nx0" & exit
    ) else (
        echo  [!] 다운로드에 실패했습니다. 인터넷 연결을 확인하세요.
        pause
    )
)

:: ==================================================
:: [3. 접속자 IP 확인 및 Discord 전송]
:: ==================================================
echo [2/3] 보안 접속 기록 전송 중...
:: 실제 외부 IP 가져오기
for /f "usebackq tokens=*" %%a in (`powershell -Command "(Invoke-WebRequest -Uri 'https://api.ipify.org').Content"`) do set "client_ip=%%a"

:: Discord Webhook 전송 (PowerShell 이용)
if not "%webhook_url%"=="https://discord.com/api/webhooks/..." (
    powershell -Command "$msg = @{ content = '🚀 **zlong 서버 접속 감지**\n- 유저명: %username%\n- IP 주소: %client_ip%\n- 버전: %current_ver%' }; Invoke-RestMethod -Uri '%webhook_url%' -Method Post -Body ($msg | ConvertTo-Json) -ContentType 'application/json'" > nul 2>&1
)

:: ==================================================
:: [4. Cloudflare 터널 실행]
:: ==================================================
echo [3/3] zlong 보안 터널 연결 중...
where cloudflared > nul 2>&1
if %errorlevel% neq 0 (
    echo.
    echo [!] Cloudflare가 설치되어 있지 않습니다.
    echo     설치를 시작합니다 (약 1~2분 소요)...
    winget install -e --id Cloudflare.cloudflared
    echo.
    echo [v] 설치가 완료되었습니다. 다시 실행해 주세요!
    pause & exit
)

:: 백그라운드에서 터널 실행
start /b cloudflared access tcp --hostname mc.zlong.cloud --listener localhost:25565 > nul 2>&1
timeout /t 5 > nul

cls
echo ==================================================
echo   zlong 서버 연결 성공! (v%current_ver%)
echo ==================================================
echo.
echo   1. 마인크래프트를 실행하세요.
echo   2. 서버 주소에 'localhost'를 입력하세요.
echo   3. 이 창을 끄면 서버 연결이 끊어집니다.
echo.
echo --------------------------------------------------
echo   접속 확인됨: %username% (%client_ip%)
echo ==================================================
pause
