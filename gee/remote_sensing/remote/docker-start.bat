@echo off
chcp 65001 >nul
REM ============================================
REM GEE Remote Service - Windows 快速启动脚本
REM ============================================

echo ==========================================
echo   GEE Remote Sensing Service
echo   Docker 快速启动 (Windows)
echo ==========================================
echo.

REM 检查 Docker
where docker >nul 2>nul
if %errorlevel% neq 0 (
    echo ❌ 错误: 未安装 Docker
    echo    请先安装 Docker Desktop: https://www.docker.com/products/docker-desktop
    pause
    exit /b 1
)

REM 检查 Docker Compose
where docker-compose >nul 2>nul
if %errorlevel% neq 0 (
    echo ❌ 错误: 未安装 Docker Compose
    echo    Docker Desktop 应该已包含 Docker Compose
    pause
    exit /b 1
)

docker --version
docker-compose --version
echo.

REM 检查 GEE 凭证 (已跳过，使用服务账号)
REM if not exist "%USERPROFILE%\.config\earthengine" (
REM     echo ⚠️  警告: 未找到 GEE 凭证
REM     echo    如果您使用的是服务账号，请忽略此警告。
REM     echo.
REM )

REM 检查模型文件
if not exist "model" mkdir model
dir /b model | findstr ".pkl" >nul 2>nul
if %errorlevel% neq 0 (
    echo ⚠️  警告: model\ 目录为空
    echo    请将 .pkl 模型文件放到 model\ 目录
    echo.
)

REM 创建必要的目录
echo [1/4] 创建存储目录...
if not exist "storage\tif" mkdir storage\tif
if not exist "storage\csv" mkdir storage\csv
if not exist "storage\results" mkdir storage\results
if not exist "storage\logs" mkdir storage\logs
echo ✓ 存储目录已创建
echo.

REM 构建镜像
echo [2/4] 构建 Docker 镜像...
docker-compose build
if %errorlevel% neq 0 (
    echo ❌ 镜像构建失败
    pause
    exit /b 1
)
echo ✓ 镜像构建完成
echo.

REM 启动服务
echo [3/4] 启动服务...
docker-compose up -d
if %errorlevel% neq 0 (
    echo ❌ 服务启动失败
    pause
    exit /b 1
)
echo ✓ 服务已启动
echo.

REM 等待服务就绪
echo [4/4] 等待服务就绪...
timeout /t 5 /nobreak >nul

REM 检查服务状态
echo.
echo ==========================================
echo   服务状态
echo ==========================================
docker-compose ps
echo.

REM 健康检查
echo 正在检查 API 健康状态...
set /a count=0
:healthcheck
set /a count+=1
curl -f http://localhost:8000/api/v1/health >nul 2>nul
if %errorlevel% equ 0 (
    echo ✓ API 服务正常
    goto :success
)
if %count% lss 10 (
    timeout /t 2 /nobreak >nul
    goto :healthcheck
)
echo ⚠️  API 服务可能未就绪，请检查日志

:success
echo.
echo ==========================================
echo   ✅ 部署完成！
echo ==========================================
echo.
echo 📚 API 文档:     http://localhost:8000/docs
echo ❤️  健康检查:    http://localhost:8000/api/v1/health
echo.
echo 📊 查看日志:     docker-compose logs -f
echo 🛑 停止服务:     docker-compose down
echo 🔄 重启服务:     docker-compose restart
echo.
pause
