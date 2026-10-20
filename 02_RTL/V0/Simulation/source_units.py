"""Resolve logical HDL units from the editable grouped source files.

Quartus compiles the grouped files directly. Simulation extracts selected units
to its ignored output directory so real and modeled units are never duplicated.
Keep the BEGIN_SOURCE/END_SOURCE comments when editing a grouped file.
"""
from pathlib import Path
import re

class SourceTree:
    def __init__(self, root, output):
        self.root=Path(root).resolve()
        self.output=Path(output)/'units'
        self.inputs={Path(__file__).resolve()}
        self.units={}
        pattern=rb'(?m)^(?:--|//) BEGIN_SOURCE: ([^\r\n]+)\r?\n(.*?)\r?\n(?:--|//) END_SOURCE: \1\r?$'
        for owner in sorted(list(self.root.glob('*.vhd'))+list(self.root.glob('*.sv'))):
            for match in re.finditer(pattern,owner.read_bytes(),re.S):
                name=match.group(1).decode('ascii')
                if name in self.units:raise ValueError('Duplicate source unit: '+name)
                self.units[name]=(owner,match.group(2))

    def resolve(self, name):
        for path in [self.root/name,self.root/'ROM'/name]:
            if path.is_file():
                self.inputs.add(path.resolve());return path
        raise FileNotFoundError(name)

    def file(self, name):
        if name not in self.units:return self.resolve(name)
        owner,data=self.units[name];self.inputs.add(owner)
        if Path(name).name!=name:raise ValueError('Unit name must be a basename')
        self.output.mkdir(parents=True,exist_ok=True)
        path=self.output/name
        if not path.exists() or path.read_bytes()!=data:path.write_bytes(data)
        return path

    def read(self, name):
        if name in self.units:
            owner,data=self.units[name];self.inputs.add(owner)
            return data.decode('utf-8').replace('\r\n','\n')
        return self.resolve(name).read_text(encoding='utf-8')

    def ledger(self, files):
        return sorted(set(map(Path,files))|self.inputs,key=str)
