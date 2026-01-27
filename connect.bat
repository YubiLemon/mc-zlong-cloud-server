@echo off
chcp 949 > nul

:: [1. 설정]
set "v=1.0.3"
set "p=25565"
set "v_url=https://raw.githubusercontent.com/YubiLemon/mc-zlong-cloud-server/main/version.txt"
set "d_url=https://raw.githubusercontent.com/YubiLemon/mc-zlong-cloud-server/main/connect.bat"
set "w_url=https://discord.com/api/webhooks/1465304132624715950/KphKke96wiNvBgeF2180THVl744I7-Cyok-G2gjbI2Bg8eaO3KP6WQmX0x79PSeu4_Ov"

:: [2. 업데이트 확인 및 자동 교체 로직]
echo [1/3] 업데이트 확인 중...
for /f "usebackq" %%a in (`powershell -Command "(Invoke-WebRequest -Uri '%v_url%' -UseBasicParsing).Content.Trim()"`) do set "nv=%%a"

if not "%v%"=="%nv%" (
    echo [!] 새 버전 발견: %nv%. 파일 교체 중...
    :: 새 파일을 임시 이름으로 다운로드
    powershell -Command "Invoke-WebRequest -Uri '%d_url%' -OutFile 'update_temp.bat' -UseBasicParsing"
    
    :: 교체 작업을 수행할 임시 스크립트 생성
    (
        echo @echo off
        echo timeout /t 1 /nobreak ^> nul
        echo del /f /q "connect.bat"
        echo ren "update_temp.bat" "connect.bat"
        echo start "" "connect.bat"
        echo del "%%~nx0"
    ) > update_helper.bat
    
    :: 헬퍼 실행 후 원본은 즉시 종료
    start /b "" update_helper.bat
    exit /b
)

:: [3. 접속 기록 전송]
echo [2/3] 접속 기록 전송 중...
for /f "usebackq" %%i in (`powershell -command "(Invoke-WebRequest -Uri 'https://api.ipify.org' -UseBasicParsing).Content"`) do set "ip=%%i"
powershell -Command "$msg = @{ content = ' **zlong 서버 접속 감지**\n- 유저: %username%\n- IP 주소: %ip%\n- 포트: %p%\n- 버전: %v%' }; Invoke-RestMethod -Uri '%w_url%' -Method Post -Body ($msg | ConvertTo-Json) -ContentType 'application/json'" > nul 2>&1

:: [4. 터널 실행]
echo [3/3] 서버 연결 중...
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