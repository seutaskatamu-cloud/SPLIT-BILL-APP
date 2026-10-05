@echo off
title Patungan Production Web Preview
echo ========================================================
echo   PATUNGAN - Production Web Bundle Preview
echo   Menjalankan server lokal pada http://localhost:8080 ...
echo ========================================================
echo.

cd /d "%~dp0build\web"

if not exist index.html (
    echo [ERROR] Folder build\web belum dibuat atau index.html tidak ditemukan.
    echo Jalankan 'flutter build web --release' terlebih dahulu.
    pause
    exit /b 1
)

echo Membuka browser pada http://localhost:8080 ...
start http://localhost:8080

echo.
echo Server berjalan. Tekan Ctrl+C untuk menghentikan server.
echo ========================================================
python -m http.server 8080
