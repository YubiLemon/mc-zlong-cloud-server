@echo off
chcp 949 > nul

:: [설정]
set "v=1.0.1"
set "p=25565"
set "v_url=https://raw.githubusercontent.com/YubiLemon/mc-zlong-cloud-server/main/version.txt"
set "d_url=https://raw.githubusercontent.com/YubiLemon/mc-zlong-cloud-server/main/connect.bat"
set "w_url=https://discord.com/api/webhooks/1465304132624715950/KphKke96wiNvBgeF2180THVl744I7-Cyok-G2gjbI2Bg8eaO3KP6WQmX0x79PSeu4_Ov"

echo [1/3] 업데이트 확인 중...
powershell -Command "$nv = (Invoke-WebRequest -Uri '%v_url%' -UseBasicParsing).Content.Trim(); if ('%v%' -ne $nv) { Invoke-WebRequest -Uri '%d_url%' -OutFile 'connect.bat' -UseBasicParsing; start connect.bat; exit }"

echo [2/3] 접속 알림 전송 중...
:: 실제 IP와 포트 정보를 수집하여 전송
for /f "usebackq" %%i in (`powershell -command "(iwr 'https://api.ipify.org' -UseBasicParsing).Content"`) do set "ip=%%i"
powershell -Command "$msg = @{ content = ' **zlong 서버 접속 감지**\n- 유저: %username%\n- IP 주소: %ip%\n- 포트: %p%\n- 버전: %v%' }; Invoke-RestMethod -Uri '%w_url%' -Method Post -Body ($msg | ConvertTo-Json) -ContentType 'application/json'" > nul 2>&1

echo [3/3] zlong 보안 터널 연결 중...
:: 백그라운드에서 클라우드플레어 실행
start /b cloudflared access tcp --hostname mc.zlong.cloud --listener localhost:%p% > nul 2>&1
timeout /t 5 > nul

cls
echo ==================================================
echo   zlong 서버 연결 성공! (v%v%)
echo ==================================================
echo   마인크래프트 주소: localhost:%p%
echo   접속 확인됨: %username% (%ip%:%p%)
echo ==================================================
pause