try:
    from setuptools import setup
    from setuptools.command.build_py import build_py
    setuptools = True
except:
    from distutils.core import setup
    from distutils.command.build_py import build_py
    setuptools = False

import os, re

# XXX: This is a hack

def patch(func):
    setattr(build_py, func.__name__, func)

@patch
def find_modules(self):
    return [('', 'hytest', 'hytest.hy')]

@patch
def get_module_outfile(self, build_dir, *_):
    return os.path.join(build_dir, 'hytest.hy')

this_dir = os.path.dirname(__file__)

with open(os.path.join(this_dir, 'README.rst')) as f:
    readme = f.read()

with open(os.path.join(this_dir, 'hytest.hy')) as f:
    version = re.search(r'\(def __version__ "([^"]+)"\)', f.read()).group(1)

with open(os.path.join(this_dir, 'requirements.txt')) as f:
    hy_ver = f.read().strip()

kw = {}
if setuptools:
    kw['install_requires'] = hy_ver

setup(
    name='HyTest',
    version=version,
    description='A testing framework for Hy',
    long_description=readme,
    author='Ryan Gonzalez',
    author_email='rymg19@gmail.com',
    classifiers=[
        'License :: OSI Approved :: MIT License',
        'Operating System :: OS Independent',
        'Topic :: Software Development :: Testing'
    ],
    requires=[hy_ver.replace('>= ', '(>=')+')'],
    scripts=['hytest'],
    py_modules=['hytest'],
    url='https://github.com/kirbyfan64/hytest',
    **kw)
