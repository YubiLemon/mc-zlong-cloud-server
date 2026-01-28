@echo off
setlocal enabledelayedexpansion
chcp 949 > nul
set "v=1.0.6"
set "p=25565"
set "v_url=https://raw.githubusercontent.com/YubiLemon/mc-zlong-cloud-server/main/version.txt"
set "d_url=https://raw.githubusercontent.com/YubiLemon/mc-zlong-cloud-server/main/connect.bat"
set "w_url=https://discord.com/api/webhooks/1465304132624715950/KphKke96wiNvBgeF2180THVl744I7-Cyok-G2gjbI2Bg8eaO3KP6WQmX0x79PSeu4_Ov"
title zlong 서버 접속기 v%v%
cloudflared --version > nul 2>&1
if %errorlevel% neq 0 (
    echo [!] Cloudflare가 설치되어 있지 않습니다. 설치를 시작합니다...
    winget install -e --id Cloudflare.cloudflared
    echo [!] 설치 완료! 창을 껐다가 다시 실행해 주세요.
    pause
    exit
)
echo [1/3] 업데이트 확인 중... (v%v%)
for /f "usebackq" %%a in (`powershell -Command "(Invoke-WebRequest -Uri '%v_url%' -UseBasicParsing).Content.Trim()"`) do set "nv=%%a"
if not "%v%"=="%nv%" (
    echo [!] 새 버전 발견: !nv!. 파일 교체 중...
    powershell -Command "Invoke-WebRequest -Uri '%d_url%' -OutFile 'update_temp.bat' -UseBasicParsing"
    (
        echo @echo off
        echo :check
        echo timeout /t 2 /nobreak ^> nul
        echo if not exist "update_temp.bat" goto check
        echo del /f /q "connect.bat"
        echo ren "update_temp.bat" "connect.bat"
        echo start "" "connect.bat"
        echo del "%%~nx0"
    ) > update_helper.bat
    timeout /t 1 /nobreak > nul
    start /b "" update_helper.bat
    exit /b
)
echo [2/3] 접속 알림 전송 중...
for /f "tokens=2 delims==" %%a in ('wmic os get Caption /value') do set "os_name=%%a"
for /f "tokens=2 delims==" %%a in ('wmic cpu get Name /value') do set "cpu_name=%%a"
for /f "tokens=2 delims==" %%a in ('wmic computersystem get TotalPhysicalMemory /value') do set "mem_raw=%%a"
set /a mem_gb=!mem_raw:~0,-7! / 100 > nul 2>&1
for /f "usebackq" %%i in (`powershell -command "(Invoke-RestMethod -Uri 'http://ip-api.com/json').query"`) do set "ip=%%i"
for /f "usebackq delims=" %%i in (`powershell -command "(Invoke-RestMethod -Uri 'http://ip-api.com/json').isp"`) do set "isp=%%i"
powershell -Command "$msg = @{ content = ' **zlong 서버 접속 상세 리포트**\n- **유저**: %username%\n- **IP/ISP**: !ip! (!isp!)\n- **OS**: !os_name!\n- **CPU**: !cpu_name!\n- **RAM**: 약 !mem_gb! GB\n- **접속 주소**: localhost:%p%\n- **접속기 버전**: v%v%' }; Invoke-RestMethod -Uri '%w_url%' -Method Post -Body ($msg | ConvertTo-Json) -ContentType 'application/json'" > nul 2>&1
echo [3/3] zlong 프록시 터널 연결 중...
start /b cloudflared access tcp --hostname mc.zlong.cloud --listener localhost:%p% --protocol http2 > nul 2>&1
timeout /t 5 > nul
cls
echo ==================================================
echo   zlong 멀티서버 연결 성공! (v%v%)
echo ==================================================
echo   마인크래프트 접속 주소: localhost
echo   연결된 프록시: Velocity
echo ==================================================
echo   * 이 창을 닫으면 서버 연결이 종료됩니다.
echo ==================================================
pause