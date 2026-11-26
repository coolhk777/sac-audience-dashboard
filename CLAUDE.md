# CLAUDE.md

이 파일은 이 프로젝트에서 작업할 때 Claude Code가 참고하는 안내서입니다.

## 프로젝트 개요

예술의전당 공연·전시 입장객 현황 데이터를 시각화하는 대시보드 프로젝트입니다. 결과물은 더블클릭으로 바로 열리는 단일 HTML 파일(`예술의전당_입장객_대시보드.html`)이며, 서버나 외부 라이브러리 없이 브라우저 안에서만 동작합니다.

## 언어

- 사용자에게는 항상 **한국어**로 답합니다.
- 코드, 명령어, 파일명은 원래 표기대로 둡니다.

## 폴더 구조

```
dashboard/
├── archive/   # 더 이상 쓰지 않는 파일, 이전 버전 보관용
├── assets/    # 원본 데이터 및 정적 자원(이미지, 엑셀 등)
│   └── 예술의전당_공연및전시_입장객현황_통합_20251231.xlsx
├── docs/      # 기획서, 데이터 설명, 회의록 등 문서
│   └── 데이터_분석_KPI_제안.md        # 컬럼 분류·KPI·분석 질문·데이터 문제
├── src/       # 대시보드 소스 코드
│   ├── dashboard.template.html        # HTML·CSS·JS 본체 (__DEFAULT_DATA__ 자리에 데이터 삽입)
│   ├── build_data.ps1                 # 분석용 데이터 TSV → data.json (필요한 열만, 사전 인코딩)
│   ├── data.json                      # 내장용 기본 데이터
│   └── build.ps1                      # 템플릿 + data.json → 최종 HTML 생성
├── 예술의전당_입장객_대시보드.html     # 빌드 결과물 (직접 수정하지 말 것)
└── CLAUDE.md
```

### 빌드

- 코드 수정은 `src/dashboard.template.html`에서 하고, `src/build.ps1`을 실행해 최종 HTML을 다시 만듭니다.
- 이 PC에는 Python·Node가 없어 PowerShell 스크립트로 처리합니다. 한글이 든 `.ps1`은 **UTF-8 BOM**으로 저장해야 PowerShell 5.1에서 깨지지 않습니다.
- 헤더 이름 매핑은 템플릿 JavaScript 맨 위의 `COLUMN_MAP`에서 고칩니다.

### 배포

- GitHub(Public): https://github.com/coolhk777/sac-audience-dashboard (`main` 브랜치)
- Vercel: https://sac-audience-dashboard.vercel.app — `main`에 push하면 자동 재배포. 빌드 없이 정적 파일 그대로 서빙하고, `index.html`이 대시보드로 이동시킴
- 원본 엑셀(`assets/*.xlsx`)은 `.gitignore`로 제외
- 이 저장소의 커밋 이메일은 GitHub noreply 주소로 설정되어 있음(공개 저장소에 개인 이메일 노출 방지)

### 폴더별 규칙

- **`archive/`**: 삭제하기 애매한 파일은 지우지 말고 이곳으로 옮깁니다.
- **`assets/`**: 원본 데이터는 수정하지 않습니다. 가공한 데이터가 필요하면 별도 파일로 저장합니다.
- **`docs/`**: 프로젝트 관련 문서는 이곳에 둡니다.
- **`src/`**: 모든 소스 코드는 이 폴더 안에 작성합니다.

## 데이터

- `assets/예술의전당_공연및전시_입장객현황_통합_20251231.xlsx` (약 6.9MB)
  - 예술의전당 공연 및 전시 입장객 현황 통합 자료 (2025-12-31 기준)
