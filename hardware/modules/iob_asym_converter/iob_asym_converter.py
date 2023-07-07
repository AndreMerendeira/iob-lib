import os
import shutil

from iob_module import iob_module
from setup import setup

from iob_utils import iob_utils
from iob_reg import iob_reg
from iob_ram_2p import iob_ram_2p
from iob_clkenrst_portmap import iob_clkenrst_portmap


class iob_asym_converter(iob_module):
    name = "iob_asym_converter"
    version = "V0.10"
    flows = "sim"
    setup_dir = os.path.dirname(__file__)

    @classmethod
    def _run_setup(cls):
        super()._run_setup()

        # Setup dependencies

        iob_utils.setup()
        iob_reg.setup()
        iob_clkenrst_portmap.setup()

        iob_ram_2p.setup(purpose="simulation")

        # Setup flows of this core using LIB setup function
        setup(cls, disable_file_gen=True)
