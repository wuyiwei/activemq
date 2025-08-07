@echo off
setlocal enabledelayedexpansion

REM 配置变量
set ACTIVEMQ_HOME=D:\apache-activemq-5.15.0
set SOURCE_DIR=D:\apache-activemq-5.15.0-src
set BROKER_JAR=%SOURCE_DIR%\activemq-broker\target\activemq-broker-5.15.0.jar
set TARGET_JAR=%ACTIVEMQ_HOME%\lib\activemq-broker-5.15.0.jar

REM 停止ActiveMQ服务
echo [1/4] 停止ActiveMQ服务...
cd /d %ACTIVEMQ_HOME%\bin
call activemq stop
IF %ERRORLEVEL% NEQ 0 (
    echo 警告：停止服务时出现错误，但继续执行...
)

REM 等待服务完全停止
echo 等待服务完全停止...
TIMEOUT /T 3 /NOBREAK >nul

REM 编译项目
echo [2/4] 开始编译activemq-broker项目...
cd /d %SOURCE_DIR%
echo 执行命令: mvn clean install -pl activemq-broker -DskipTests
call mvn clean install -pl activemq-broker -DskipTests
IF %ERRORLEVEL% NEQ 0 (
    echo 错误：编译失败，请检查错误信息。
    pause
    exit /b 1
)

REM 检查编译结果
echo [3/4] 检查编译结果...
IF NOT EXIST "%BROKER_JAR%" (
    echo 错误：源JAR文件不存在 - %BROKER_JAR%
    pause
    exit /b 1
) ELSE (
    echo 找到编译后的JAR文件: %BROKER_JAR%
)

REM 替换JAR文件
echo 替换JAR文件: %BROKER_JAR% -^> %TARGET_JAR%
COPY /Y "%BROKER_JAR%" "%TARGET_JAR%"
IF %ERRORLEVEL% NEQ 0 (
    echo 错误：替换JAR文件失败。
    pause
    exit /b 1
) ELSE (
    echo JAR文件替换成功！
)

REM 启动ActiveMQ服务
echo [4/4] 启动ActiveMQ服务...
cd /d %ACTIVEMQ_HOME%\bin
rem 启动ActiveMQ服务在后台运行
start /b call activemq start

echo 服务已在当前窗口后台启动...
echo 注意：后台运行时输出将不可见，如需查看日志请检查ActiveMQ安装目录下的logs文件夹

REM 完成
echo 操作完成！ActiveMQ服务已重新启动。
endlocal