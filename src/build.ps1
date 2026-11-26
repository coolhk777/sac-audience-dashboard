# 단일 HTML 대시보드 빌드
# 1) 엑셀 '분석용 데이터' 시트 → TSV 변환은 최초 1회 (scratch 단계, read_sheet 결과를 -Tsv로 전달)
# 2) TSV → data.json (build_data.ps1)
# 3) dashboard.template.html 의 __DEFAULT_DATA__ 자리에 data.json을 넣어 최종 HTML 생성
# 사용법: .\build.ps1  (data.json이 이미 있으면 3단계만 수행)
param([string]$Tsv = '')

$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$root = Split-Path -Parent $here
$dataPath = Join-Path $here 'data.json'
if ($Tsv) { & (Join-Path $here 'build_data.ps1') -Tsv $Tsv -Out $dataPath }
if (-not (Test-Path $dataPath)) { throw "data.json이 없습니다. -Tsv 로 분석용 데이터 TSV를 지정하세요." }

$utf8 = New-Object System.Text.UTF8Encoding($false)
$tpl = [System.IO.File]::ReadAllText((Join-Path $here 'dashboard.template.html'), $utf8)
$data = [System.IO.File]::ReadAllText($dataPath, $utf8).Replace('</', '<\/')   # </script> 방지
$out = Join-Path $root '예술의전당_입장객_대시보드.html'
[System.IO.File]::WriteAllText($out, $tpl.Replace('__DEFAULT_DATA__', $data), $utf8)
"생성: $out ($([math]::Round((Get-Item $out).Length / 1MB, 2)) MB)"
