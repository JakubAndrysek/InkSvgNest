import sys
from ruamel.yaml import YAML

d = dict(a=dict(b=2),c=[3, 4])
yaml = YAML()
yaml.dump(d, sys.stdout)
