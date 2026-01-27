@echo off
chcp 949 > nul

:: [설정]
set "v=1.0.2"
set "p=25565"
set "v_url=https://raw.githubusercontent.com/YubiLemon/mc-zlong-cloud-server/main/version.txt"
set "d_url=https://raw.githubusercontent.com/YubiLemon/mc-zlong-cloud-server/main/connect.bat"
set "w_url=https://discord.com/api/webhooks/1465304132624715950/KphKke96wiNvBgeF2180THVl744I7-Cyok-G2gjbI2Bg8eaO3KP6WQmX0x79PSeu4_Ov"

echo [1/3] 업데이트 확인 중... (v%v%)
for /f "usebackq" %%a in (`powershell -Command "(Invoke-WebRequest -Uri '%v_url%' -UseBasicParsing).Content.Trim()"`) do set "nv=%%a"

if not "%v%"=="%nv%" (
    echo [!] 새 버전 발견: %nv%. 파일 교체 중...
    :: 1. 새 파일을 임시 이름으로 다운로드
    powershell -Command "Invoke-WebRequest -Uri '%d_url%' -OutFile 'temp_update.bat' -UseBasicParsing"
    
    :: 2. 덮어씌우기 명령 생성 (자기 자신을 지우고 이름을 바꾸는 방식)
    if exist "temp_update.bat" (
        echo @echo off > update_helper.bat
        echo timeout /t 1 /nobreak ^> nul >> update_helper.bat
        echo del "connect.bat" >> update_helper.bat
        echo ren "temp_update.bat" "connect.bat" >> update_helper.bat
        echo start "" "connect.bat" >> update_helper.bat
        echo del "%%~nx0" >> update_helper.bat
        
        start /b "" update_helper.bat
        exit
    )
)

:: [2/3] 접속 알림 전송 (IP 및 포트 포함)
echo [2/3] 접속 알림 전송 중...
for /f "usebackq" %%i in (`powershell -command "(Invoke-WebRequest -Uri 'https://api.ipify.org' -UseBasicParsing).Content"`) do set "ip=%%i"
powershell -Command "$msg = @{ content = '**zlong 서버 접속 감지**\n- 유저: %username%\n- IP 주소: %ip%\n- 포트: %p%\n- 버전: %v%' }; Invoke-RestMethod -Uri '%w_url%' -Method Post -Body ($msg | ConvertTo-Json) -ContentType 'application/json'" > nul 2>&1

:: [3/3] 서버 연결
echo [3/3] zlong 보안 터널 연결 중...
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