import os
import shutil

from iob_module import iob_module
from axi_m_port import axi_m_port
from axi_m_write_port import axi_m_write_port
from axi_m_read_port import axi_m_read_port
from axi_m_m_write_portmap import axi_m_m_write_portmap
from axi_m_m_read_portmap import axi_m_m_read_portmap
from axis2axi import axis2axi
from axis2axi_in import axis2axi_in
from axis2axi_out import axis2axi_out
from iob_fifo_sync import iob_fifo_sync
from iob_counter import iob_counter
from iob_reg_r import iob_reg_r
from iob_reg_re import iob_reg_re
from iob_asym_converter import iob_asym_converter
from AxiDelay import AxiDelay
from axi_ram import axi_ram
from iob_ram_t2p import iob_ram_t2p

class axis2axi(iob_module):
    name='axis2axi'
    version='V0.10'
    setup_dir=os.path.dirname(__file__)

    @classmethod
    def _run_setup(cls):
        out_dir = super()._run_setup()
        # Copy source to build directory
        shutil.copyfile(os.path.join(cls.setup_dir, 'axis2axi.v'), os.path.join(cls.build_dir, out_dir, 'axis2axi.v'))
        # Setup dependencies

        axi_m_port.setup()                
        axi_m_write_port.setup()        
        axi_m_read_port.setup()        
        axi_m_m_write_portmap.setup()        
        axi_m_m_read_portmap.setup()        
                
        axis2axi.setup()                
        axis2axi_in.setup()                
        axis2axi_out.setup()                
        iob_fifo_sync.setup()                
        iob_counter.setup()        
        iob_reg_r.setup()        
        iob_reg_re.setup()        
        iob_asym_converter.setup()        
                
        AxiDelay.setup(purpose="simulation")        
        axi_ram.setup(purpose="simulation")        
        iob_ram_t2p.setup(purpose="simulation")        
