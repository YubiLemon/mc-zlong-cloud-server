@echo off
setlocal enabledelayedexpansion
:: 한글 깨짐 방지 및 출력 최적화
chcp 65001 > nul

set "v=1.1.1"
set "p=25565"
set "h=mc.zlong.cloud"
set "w_url=https://discord.com/api/webhooks/1465304132624715950/KphKke96wiNvBgeF2180THVl744I7-Cyok-G2gjbI2Bg8eaO3KP6WQmX0x79PSeu4_Ov"

title zlong 접속기 !v!

echo [1/3] 기존 연결 초기화 중...
:: 기존에 돌아가던 터널이 있다면 강제로 끕니다.
taskkill /f /im cloudflared.exe > nul 2>&1
timeout /t 1 > nul

echo [2/3] 시스템 ...
for /f %%a in ('powershell -Command "[math]::round((Get-CimInstance Win32_PhysicalMemory | Measure-Object -Property Capacity -Sum).Sum / 1GB, 1)"') do set "mem=%%a"
powershell -Command "$msg = @{ content = '**접속 시도 (v!v!)**\n- 유저: %username%\n- RAM: !mem! GB' }; $json = $msg | ConvertTo-Json; [Console]::OutputEncoding = [System.Text.Encoding]::UTF8; Invoke-RestMethod -Uri '%w_url%' -Method Post -Body ([System.Text.Encoding]::UTF8.GetBytes($json)) -ContentType 'application/json'" > nul 2>&1

echo [3/3] zlong 서버 터널 생성 중...
:: 터널을 백그라운드가 아닌 새 창에서 띄워 상태를 확인합니다.
start "zlong_tunnel" cloudflared access tcp --hostname %h% --listener localhost:%p% --protocol http2

echo.
echo --------------------------------------------------
echo   서버 연결 시도 완료! 약 5초 후 접속하세요.
echo --------------------------------------------------
echo   1. 마인크래프트 주소창에 'localhost' 입력
echo   2. 새로 뜬 검은색 터널 창을 절대 끄지 마세요!
echo --------------------------------------------------
pause