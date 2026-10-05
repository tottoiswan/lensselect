@echo off
title AutoSelect Launcher - Ttwins Selection
color 0b
echo ================================================================
echo        AUTOSELECT FILE - TTWINS SELECTION (LOCAL SERVER)
echo ================================================================
echo.
echo Membuka AutoSelect dengan izin akses harddisk penuh (Read/Write)...
echo Browser Chrome / Edge Anda akan terbuka secara otomatis.
echo.
echo Catatan: Jendela ini adalah server lokal sementara.
echo Jangan tutup jendela ini selama Anda menggunakan AutoSelect.
echo ================================================================
echo.

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "$port = 8765; ^
  $url = 'http://localhost:' + $port + '/AutoSelect.html'; ^
  Start-Process $url; ^
  $listener = New-Object System.Net.HttpListener; ^
  $listener.Prefixes.Add('http://localhost:' + $port + '/'); ^
  $listener.Start(); ^
  Write-Host 'Server lokal aktif di' $url -ForegroundColor Green; ^
  Write-Host 'Tekan Ctrl+C di jendela ini jika sudah selesai.' -ForegroundColor Yellow; ^
  while ($listener.IsListening) { ^
    $ctx = $listener.GetContext(); ^
    $req = $ctx.Request; ^
    $res = $ctx.Response; ^
    $cleanPath = $req.Url.LocalPath.TrimStart('/'); ^
    if ([string]::IsNullOrWhiteSpace($cleanPath)) { $cleanPath = 'AutoSelect.html' }; ^
    $localFile = Join-Path (Get-Location) ($cleanPath -replace '/', '\'); ^
    if (Test-Path $localFile -PathType Leaf) { ^
      $bytes = [System.IO.File]::ReadAllBytes($localFile); ^
      $res.ContentLength64 = $bytes.Length; ^
      if ($localFile.EndsWith('.html')) { $res.ContentType = 'text/html; charset=utf-8' } ^
      elseif ($localFile.EndsWith('.js')) { $res.ContentType = 'application/javascript; charset=utf-8' } ^
      elseif ($localFile.EndsWith('.css')) { $res.ContentType = 'text/css; charset=utf-8' } ^
      $res.OutputStream.Write($bytes, 0, $bytes.Length); ^
    } else { ^
      $res.StatusCode = 404; ^
    }; ^
    $res.OutputStream.Close(); ^
  }"

pause
