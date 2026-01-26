@echo off
chcp 949 > nul
setlocal enabledelayedexpansion

:: [1. 설정 영역] - 따옴표 위치를 엄격하게 맞췄습니다.
set "v=1.0.0"
set "v_url=https://raw.githubusercontent.com/YubiLemon/mc-zlong-cloud-server/main/version.txt"
set "d_url=https://raw.githubusercontent.com/YubiLemon/mc-zlong-cloud-server/main/connect.bat"
set "w_url=https://discord.com/api/webhooks/1465304132624715950/KphKke96wiNvBgeF2180THVl744I7-Cyok-G2gjbI2Bg8eaO3KP6WQmX0x79PSeu4_Ov"

title zlong 서버 접속기 v%v%

:: [2. 업데이트 확인]
echo [1/3] 업데이트 확인 중... (v%v%)
:: 오류의 주범이었던 괄호 로직을 단순화했습니다.
for /f "usebackq tokens=*" %%a in (`powershell -Command "(Invoke-WebRequest -Uri '%v_url%' -UseBasicParsing).Content.Trim()"`) do set "nv=%%a"

if not "%v%"=="%nv%" (
    echo [!] 새 버전 발견: %nv%
    powershell -Command "Invoke-WebRequest -Uri '%d_url%' -OutFile 'connect_new.bat' -UseBasicParsing"
    if exist "connect_new.bat" (
        start "" "connect_new.bat"
        exit
    )
)

:: [3. IP 전송]
echo [2/3] 접속 기록 전송 중...
for /f "usebackq tokens=*" %%i in (`powershell -Command "(Invoke-WebRequest -Uri 'https://api.ipify.org' -UseBasicParsing).Content"`) do set "ip=%%i"
powershell -Command "$msg = @{ content = ' **접속 감지**\n- 유저: %username%\n- IP: %ip%' }; Invoke-RestMethod -Uri '%w_url%' -Method Post -Body ($msg | ConvertTo-Json) -ContentType 'application/json'" > nul 2>&1

:: [4. 터널 실행]
echo [3/3] 서버 연결 중...
start /b cloudflared access tcp --hostname mc.zlong.cloud --listener localhost:25565 > nul 2>&1
timeout /t 5 > nul

cls
echo ==================================================
echo   zlong 서버 연결 성공! (v%v%)
echo ==================================================
echo   마인크래프트 주소: localhost
echo ==================================================
pause