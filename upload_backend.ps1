Set-Location c:\Users\loli\localboost

$SSH = "ubuntu@sirius-djibouti.com"
$PORT = "2222"

$uploads = @(
    "backend\apps\enrollments\models.py|/tmp/enrollment_models.py",
    "backend\apps\enrollments\serializers.py|/tmp/enrollment_serializers.py",
    "backend\apps\enrollments\views.py|/tmp/enrollment_views.py",
    "backend\apps\enrollments\urls.py|/tmp/enrollment_urls.py",
    "backend\apps\enrollments\migrations\0002_enrollment_qr_token.py|/tmp/0002_enrollment_qr_token.py",
    "backend\apps\transactions\models.py|/tmp/transaction_models.py",
    "backend\apps\transactions\migrations\0002_stamptransaction_idempotency.py|/tmp/0002_stamptransaction_idempotency.py",
    "backend\apps\accounts\serializers.py|/tmp/accounts_serializers.py"
)

foreach ($entry in $uploads) {
    $parts = $entry -split "\|"
    $local = $parts[0]
    $remote = $parts[1]
    $result = scp -P $PORT $local "${SSH}:${remote}" 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "OK: $local"
    } else {
        Write-Host "FAIL: $local - $result"
    }
}

Write-Host "Upload complete."
