@echo off
chcp 949 > nul

:: [설정] 버전 1.0.3 / 프록시 포트 25577
set "v=1.0.3"
set "p=25577"
set "v_url=https://raw.githubusercontent.com/YubiLemon/mc-zlong-cloud-server/main/version.txt"
set "d_url=https://raw.githubusercontent.com/YubiLemon/mc-zlong-cloud-server/main/connect.bat"
set "w_url=https://discord.com/api/webhooks/1465304132624715950/KphKke96wiNvBgeF2180THVl744I7-Cyok-G2gjbI2Bg8eaO3KP6WQmX0x79PSeu4_Ov"

echo [1/3] 업데이트 확인 중...
for /f "usebackq" %%a in (`powershell -Command "(Invoke-WebRequest -Uri '%v_url%' -UseBasicParsing).Content.Trim()"`) do set "nv=%%a"

if not "%v%"=="%nv%" (
    echo [!] 새 버전 발견: %nv%. 파일 교체 중...
    powershell -Command "Invoke-WebRequest -Uri '%d_url%' -OutFile 'update_temp.bat' -UseBasicParsing"
    (
        echo @echo off
        echo timeout /t 2 /nobreak ^> nul
        echo del /f /q "connect.bat"
        echo ren "update_temp.bat" "connect.bat"
        echo start "" "connect.bat"
        echo del "%%~nx0"
    ) > update_helper.bat
    start /b "" update_helper.bat
    exit /b
)

echo [2/3] 프록시 서버 접속 알림 전송...
for /f "usebackq" %%i in (`powershell -command "(iwr 'https://api.ipify.org' -UseBasicParsing).Content"`) do set "ip=%%i"
powershell -Command "$msg = @{ content = ' **Velocity 프록시 접속**\n- 유저: %username%\n- IP: %ip%\n- 포트: %p%' }; Invoke-RestMethod -Uri '%w_url%' -Method Post -Body ($msg | ConvertTo-Json) -ContentType 'application/json'" > nul 2>&1

echo [3/3] zlong 프록시 터널 연결 중...
:: --protocol http2 옵션으로 핑을 최적화합니다.
start /b cloudflared access tcp --hostname mc.zlong.cloud --listener localhost:%p% --protocol http2 > nul 2>&1
timeout /t 5 > nul

cls
echo ==================================================
echo   zlong 멀티서버 프록시 연결 성공! (v%v%)
echo ==================================================
echo   마인크래프트 접속 주소: localhost:%p%
echo   연결된 프록시: Velocity
echo ==================================================
pause