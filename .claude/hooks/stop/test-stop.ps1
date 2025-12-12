# Minimal Stop hook test
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
"[$timestamp] STOP HOOK FIRED!" | Out-File -FilePath "c:\GoA\stop-test.txt" -Append
exit 0
