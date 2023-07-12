import os

from iob_module import iob_module

from iob_utils import iob_utils
from iob_reg import iob_reg
from iob_ram_2p import iob_ram_2p


class iob_asym_converter(iob_module):
    name = "iob_asym_converter"
    version = "V0.10"
    flows = "sim"
    setup_dir = os.path.dirname(__file__)

    @classmethod
    def _specific_setup(cls):
        # Setup dependencies

        iob_utils.setup()
        iob_reg.setup()
        iob_module.generate("clk_en_rst_portmap")
        iob_module.generate("clk_en_rst_port")

        iob_ram_2p.setup(purpose="simulation")
