"""Read-only verification of the dated release; no serial port or programming."""
from pathlib import Path
import hashlib
import json

HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[1]
record=json.loads((HERE/'checks.json').read_text(encoding='utf-8'))
errors=[]
def check(path,expected):
    if not path.is_file():
        errors.append('Missing: '+path.relative_to(ROOT).as_posix())
    elif hashlib.sha256(path.read_bytes()).hexdigest()!=expected:
        errors.append('SHA256 mismatch: '+path.relative_to(ROOT).as_posix())
for rel,expected in record['source_sha256'].items():
    check(ROOT/'02_RTL/V0'/rel,expected)
check(ROOT/'02_RTL/V0/output_files/UsMimoTestBench.sof',record['main_sof_sha256'])
check(ROOT/'03_SW/UsMimoTestBench/bin/Release/UsMimoTestBench.exe',record['ui_exe_sha256'])
for rel,expected in record.get('verification_input_sha256',{}).items():
    check(ROOT/rel,expected)
if errors:
    raise SystemExit('\n'.join(errors))
print('PASS '+record['branch']+': '+str(len(record['source_sha256']))+' source files, Main SOF, GUI EXE and recorded validation inputs match the 2026-11-01 snapshot.')
print('This checks file identity only. It is not a new compile or physical ranging calibration.')
