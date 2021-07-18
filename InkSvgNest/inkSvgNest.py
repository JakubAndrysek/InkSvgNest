#!/usr/bin/env python
# coding=utf-8
#
# MIT License
#
# Copyright (c) 2021 Kuba Andrýsek
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

"""
This script 

"""
import os
import inkex
from lxml import etree
import inkex.utils
import inkex.base

class Inknest(inkex.EffectExtension):

    def add_arguments(self, pars):
        pars.add_argument("--tab", type=str, dest="tab")  # self.options.tab
        pars.add_argument("--a_mode", type=str, dest="a_mode")  # self.options.a_mode
        pars.add_argument("--r_mode", type=str, dest="r_mode")  # self.options.r_mode
        pars.add_argument("--a_file", type=str, dest="a_file")  # self.options.a_file
        pars.add_argument("--r_file", type=str, dest="r_file")  # self.options.r_file

    def yaml_write(self, data, filename):
        f = open(filename, "w+")
        for key in data:
            val = data[key]
            f.write(f"{key}:\n- {val}\n")
        f.close()

    def yaml_read(self, data, filename):
        try:
            with open(filename) as f:
                for lineKey in f:
                    key = lineKey[:-2]
                    lineVal = next(f)
                    val = lineVal[2:-1]
                    data[key] = val
                f.close()
        except StopIteration:
            self.raise_error("End")

    def raise_error(self, message: str):
        raise inkex.AbortExtension("ERROR: %s" % message)

    def file_suffix(self, filename: str, suffix: str):
        if suffix not in filename:
            self.raise_error(f"The '{filename}' file must have a '{suffix}' extension.")

    def file_exists(self, filename: str):
        if not os.path.isfile(filename):
            self.raise_error(f"'{filename}' file is not exist")

    def file_check(self, filename: str, suffix: str):
        self.file_suffix(filename, suffix)
        self.file_exists(filename)

    def svg_to_yaml(self, yaml_file: str):
        self.file_suffix(yaml_file, ".yaml")
        data = {}

        for el in self.svg.getiterator():
            if "transform" in el.attrib:
                data[el.attrib["id"]] = [el.attrib["transform"]][0]

        self.yaml_write(data, yaml_file)

    def yaml_to_svg(self, yaml_file):
        self.file_check(yaml_file, ".yaml")
        data = {}
        self.yaml_read(data, yaml_file)

        for el in self.svg.getiterator():
            if "id" in el.attrib:
                if el.attrib["id"] in data:
                    el.transform = str(data[el.attrib["id"]])

    def svg_to_svg(self, svg_file_nested):
        self.file_check(svg_file_nested, ".svg")
        data = {}
        root = etree.parse(svg_file_nested).getroot()
        for el in root.getiterator():
            if "transform" in el.attrib:
                data[el.attrib["id"]] = [el.attrib["transform"]][0]

        for el in self.svg.getiterator():
            if "id" in el.attrib:
                if el.attrib["id"] in data:
                    el.transform = str(data[el.attrib["id"]])

    def effect(self):
        input_svg = self.document_path()
        tab = self.options.tab

        if tab == "relative":
            mode = self.options.r_mode
            r_file = self.options.r_file
            if (r_file == None):
                raise inkex.AbortExtension("Relative path input file  mustn't be empty")
            file = os.path.join(os.path.split(input_svg)[0], r_file)
        else:  # absolute and help
            mode = self.options.a_mode
            file = self.options.a_file

        if mode == "svgToYaml":
            self.svg_to_yaml(yaml_file=file)
            pass
        elif mode == "yamlToSvg":
            self.yaml_to_svg(yaml_file=file)
            pass
        elif mode == "svgToSvg":
            self.svg_to_svg(svg_file_nested=file)

        # self.debug("Mode: " + mode + "  Input/Output: " + file)


if __name__ == "__main__":
    Inknest().run()

    # For testing
    # if '/' in __file__:
    #     # We are running in PyCharm
    #     input_file = r'/home/kuba/Documents/moje/moje.svg'
    #     output_file = input_file
    #     Inknest().run([input_file, '--a_mode=' + "svgToYaml"])
    # else:
    #     # We are running in Inkscape
    #     Inknest().run()
