import sys

from lxml import etree, objectify
from ruamel.yaml import YAML

svg_file_nested = "../example/nest-manual.svg"
yaml_file_spec = "../example/nest-manual-spec.yaml"

svg_file_raw = "../example/raw.svg"
svg_file_export = "../example/nest-export.svg"


def svgToYaml(svg_file_nested, yaml_file_spec):
    yaml = YAML()
    data = {}

    root = etree.parse(svg_file_nested).getroot()
    for el in root.getiterator():
        if "transform" in el.attrib:
            data[el.attrib["id"]] = [el.attrib["transform"]]

    yaml.dump(data, sys.stdout)

    with open(yaml_file_spec, "w") as f:
        yaml.dump(data, f)


def yamlToSvg(svg_file_raw, yaml_file_spec, svg_file_export):
    yaml = YAML()
    with open(yaml_file_spec) as f:
        data = yaml.load(f)

    root = etree.parse(svg_file_raw).getroot()
    for el in root.getiterator():
        print(el.attrib)
        if "id" in el.attrib :
        # if "id" in el.attrib and "Setup" in el.attrib["id"]:
        # if "id" in el.attrib and "Setup" in el.attrib["id"] or "polyline" in el.attrib["id"]:
            if el.attrib["id"] in data:
                el.attrib["transform"] = str(data[el.attrib["id"]][0])
                print(el.attrib)
    print(root)

    et = etree.ElementTree(root)
    et.write(svg_file_export, pretty_print=True)



svgToYaml(svg_file_nested, yaml_file_spec)

yamlToSvg(svg_file_raw, yaml_file_spec, svg_file_export)
