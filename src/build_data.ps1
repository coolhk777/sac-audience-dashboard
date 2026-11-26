# 분석용 데이터 TSV(엑셀 '분석용 데이터' 시트를 변환한 파일)에서
# 대시보드에 필요한 열만 뽑아 사전(dictionary) 인코딩된 JSON으로 저장한다.
# 사용법: .\build_data.ps1 -Tsv <sheet4.tsv> -Out <data.json>
param([string]$Tsv, [string]$Out)

$lines = [System.IO.File]::ReadAllLines($Tsv, [System.Text.Encoding]::UTF8)
$h = $lines[0].Split("`t"); $ix = @{}
for ($c = 0; $c -lt $h.Length; $c++) { $ix[$h[$c]] = $c }

# 문자열 열: 사전 + 코드 배열 / 숫자 열: 숫자 배열
$strCols = [ordered]@{ field = '분야'; name = '공연·전시명'; place = '장소(표준)'; gubun = '구분'; org = '주최·기획사'; time = '시간'; slot = '시간대' }
$numCols = [ordered]@{ date = '일자'; year = '연도'; month = '월'; dow = '요일순서'; free = '무료(분석값)'; paid = '유료'; ex1 = '추가 구분 1'; ex2 = '추가 구분 2'; total = '관객수' }

$dicts = @{}; $maps = @{}; $codes = @{}; $nums = @{}
foreach ($k in $strCols.Keys) { $dicts[$k] = New-Object System.Collections.Generic.List[string]; $maps[$k] = @{}; $codes[$k] = New-Object System.Collections.Generic.List[int] }
foreach ($k in $numCols.Keys) { $nums[$k] = New-Object System.Collections.Generic.List[string] }

$n = 0; $sum = 0
for ($i = 1; $i -lt $lines.Length; $i++) {
  if (-not $lines[$i]) { continue }
  $f = $lines[$i].Split("`t")
  foreach ($k in $strCols.Keys) {
    $v = $f[$ix[$strCols[$k]]]; if ($null -eq $v) { $v = '' }
    if (-not $maps[$k].ContainsKey($v)) { $maps[$k][$v] = $dicts[$k].Count; $dicts[$k].Add($v) }
    $codes[$k].Add($maps[$k][$v])
  }
  foreach ($k in $numCols.Keys) {
    $v = $f[$ix[$numCols[$k]]]; if (-not $v) { $v = '0' }
    $nums[$k].Add($v)
  }
  $sum += [double]$f[$ix['관객수']]; $n++
}

# JSON 직접 작성 (ConvertTo-Json은 대용량에서 느림)
function JStr([string]$s) { '"' + ($s -replace '\\', '\\' -replace '"', '\"') + '"' }
$sb = New-Object System.Text.StringBuilder
[void]$sb.Append('{"n":' + $n + ',"sum":' + $sum + ',"s":{')
$first = $true
foreach ($k in $strCols.Keys) {
  if (-not $first) { [void]$sb.Append(',') }; $first = $false
  [void]$sb.Append((JStr $k) + ':[[' + (($dicts[$k] | ForEach-Object { JStr $_ }) -join ',') + '],"' + ($codes[$k] -join ',') + '"]')
}
[void]$sb.Append('},"v":{')
$first = $true
foreach ($k in $numCols.Keys) {
  if (-not $first) { [void]$sb.Append(',') }; $first = $false
  [void]$sb.Append((JStr $k) + ':"' + ($nums[$k] -join ',') + '"')
}
[void]$sb.Append('}}')
[System.IO.File]::WriteAllText($Out, $sb.ToString(), (New-Object System.Text.UTF8Encoding($false)))
"행 수: $n / 관객수 합계: $sum / 파일 크기: $((Get-Item $Out).Length) bytes"
