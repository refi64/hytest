try:
    #assert False
    from setuptools import setup
    kw = {'install_requires': 'hy >= 0.9.12'}
except:
    from distutils.core import setup
    kw = {}

# XXX: This is a hack
from distutils.command.install import install
from distutils.command.install_lib import install_lib
import os, shutil

orig_run = install_lib.run

def run(self):
    self.skip_build = True
    if not os.path.isdir(self.build_dir):
        os.mkdir(self.build_dir)
        shutil.copy('hytest.hy', os.path.join(self.build_dir, 'hytest.hy'))
    orig_run(self)

install_lib.run = run

assert install.sub_commands[0][0] == 'install_lib'
install.sub_commands[0] = (install.sub_commands[0][0], lambda *_: True)

import hy, hytest

try:
    with open('README.rst', 'r') as f:
        readme = f.read()
except:
    readme = ''

setup(name='HyTest',
      version=str(hytest.__version__),
      description='A testing framework for Hy',
      long_description=readme,
      author='Ryan Gonzalez',
      classifiers=[
        'License :: OSI Approved :: MIT License',
        'Operating System :: OS Independent',
        'Topic :: Software Development :: Testing'
      ],
      requires=['hy (>=0.9.12)'],
      scripts=['hytest'],
      **kw)
