# AGENTS.md

이 저장소의 KESE 스킬은 한국어 정본만 사용한다. 영어 스킬은 활성 정본으로 간주하지 않는다.

## 활성 스킬 이름

- `kesekit-start`
- `kesekit-check`
- `kesekit-fix`
- `kesekit-guide`

## 원본과 로컬 설치

- 원본 저장소: 이 repo
- 로컬 설치 스크립트: `scripts/install-local-skills.sh`
- 스크립트 실행 시 Codex와 Claude 로컬 활성 스킬이 함께 갱신된다

```bash
bash scripts/install-local-skills.sh
```

## 사용 방식 1: Claude/Codex가 직접 스킬 사용

### Codex

Codex에서는 아래 스킬 이름으로 직접 호출한다.

- `$kesekit-start`
- `$kesekit-check`
- `$kesekit-fix`
- `$kesekit-guide`

예:

```text
$kesekit-start 이 저장소를 KISA 기준으로 점검해줘.
```

### Claude

Claude에서는 KESE 플러그인 스킬로 직접 호출한다.

- `/kesekit-ko:kesekit-start`
- `/kesekit-ko:kesekit-check`
- `/kesekit-ko:kesekit-fix`
- `/kesekit-ko:kesekit-guide`

예:

```text
/kesekit-ko:kesekit-start
```

또는 자연어로 `kesekit-start` 사용을 명시해도 된다.

## 사용 방식 2: Claude가 Codex에게 위임

Claude가 직접 KESE 플러그인을 쓰지 않고, 터미널에서 `codex exec`를 실행해 Codex 스킬에게 작업을 위임할 수 있다.

권장 방식은 인터랙티브 TUI 제어가 아니라 작업 단위 비대화형 호출이다.

**중요: `--full-auto` 플래그 필수.** 기본 `codex exec`는 `approval: never` + `sandbox: read-only`로 실행되어 파일 수정이 불가능하다. `kesekit-fix` 등 파일 쓰기가 필요한 스킬은 반드시 `--full-auto`를 붙여야 한다 (`-a on-request` + `--sandbox workspace-write`).

```bash
# 읽기 전용 (점검/분석만)
codex exec -C /path/to/project '$kesekit-start 이 저장소를 KISA 기준으로 점검해줘'
codex exec -C /path/to/project '$kesekit-check 배포 전 보안 체크리스트를 실행해줘'

# 파일 수정 필요 (수정안/스크립트 생성)
codex exec --full-auto -C /path/to/project '$kesekit-fix 발견된 취약점에 대한 수정안과 하드닝 스크립트를 생성해줘'
codex exec --full-auto -C /path/to/project '$kesekit-guide FastAPI용 시큐어코딩 프롬프트를 만들어줘'
```

참고: `--approval` 플래그는 존재하지 않는다. sandbox 모드 직접 지정 시 `-s workspace-write`를 사용한다.

## 운영 원칙

- 일반 이름 `start`, `check`, `fix`, `guide`는 사용하지 않는다
- 항상 `kesekit-*` 이름을 사용한다
- 정본은 `plugins/kesekit-ko/skills/` 기준이다
- 스킬 갱신 후에는 설치 스크립트를 다시 실행한다
