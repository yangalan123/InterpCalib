import os

from setuptools import setup, find_packages

setup(
    name="InterpCalib",
    version="0.1",
    packages=find_packages(where=".", exclude=(
        "tests",
    )),
    package_dir={"": "."},
)
