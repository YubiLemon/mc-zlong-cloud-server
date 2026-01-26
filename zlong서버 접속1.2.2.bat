@echo off
chcp 949 > nul
setlocal enabledelayedexpansion

:: [1. 설정]
set "current_ver=1.2.2"
set "ver_url=https://raw.githubusercontent.com/YubiLemon/mc-zlong-cloud-server/main/version.txt"
:: 주소 내의 % 기호를 배치 파일이 오해하지 않도록 처리했습니다
set "download_url=https://raw.githubusercontent.com/YubiLemon/mc-zlong-cloud-server/main/zlong%%EC%%84%%9C%%EB%%B2%%94%%20%%EC%%A0%%91%%EC%%86%%9D1.2.0.bat"
set "webhook_url=https://discord.com/api/webhooks/1465304132624715950/KphKke96wiNvBgeF2180THVl744I7-Cyok-G2gjbI2Bg8eaO3KP6WQmX0x79PSeu4_Ov"

:: [2. 업데이트 확인]
echo 업데이트 확인 중... (v%current_ver%)
powershell -Command "$v = (Invoke-WebRequest -Uri '%ver_url%' -UseBasicParsing).Content.Trim(); if ($v -ne '%current_ver%') { exit 1 } else { exit 0 }"
if %errorlevel% equ 1 (
    echo [!] 새 버전 발견! 다운로드 중...
    powershell -Command "Invoke-WebRequest -Uri '%download_url%' -OutFile 'zlong_update.bat'"
    if exist "zlong_update.bat" (
        start "" "zlong_update.bat"
        (goto) 2>nul & del "%~nx0" & exit
    )
)

:: [3. IP 전송]
echo 접속 기록 전송 중...
powershell -Command "$ip = (Invoke-WebRequest -Uri 'https://api.ipify.org').Content; $msg = @{ content = '?? 접속감지: %username% / IP: ' + $ip }; Invoke-RestMethod -Uri '%webhook_url%' -Method Post -Body ($msg | ConvertTo-Json) -ContentType 'application/json'" > nul 2>&1

:: [4. 터널 실행]
start /b cloudflared access tcp --hostname mc.zlong.cloud --listener localhost:25565 > nul 2>&1
echo [v] 서버 연결 성공! localhost로 접속하세요.
pause