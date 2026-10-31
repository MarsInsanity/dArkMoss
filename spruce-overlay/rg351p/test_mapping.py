import sys, types
# Stub what the device module chain pulls in but the mapper never uses.
class _Any(types.ModuleType):
    def __getattr__(self, n):
        if n.startswith('__'): raise AttributeError(n)
        return type(n, (), {'__init__': lambda s,*a,**k: None})
import importlib.abc, importlib.machinery
REAL = ('controller', 'devices', 'utils.logger')
class Finder(importlib.abc.MetaPathFinder, importlib.abc.Loader):
    def find_spec(self, name, path, target=None):
        if name.split('.')[0] in ('controller','devices') : return None
        for f in sys.meta_path:
            if f is self: continue
            try: spec = f.find_spec(name, path, target)
            except Exception: spec = None
            if spec is not None: return None
        return importlib.machinery.ModuleSpec(name, self, is_package=True)
    def create_module(self, spec): return _Any(spec.name)
    def exec_module(self, m): m.__path__ = []
sys.meta_path.insert(0, Finder())
# usage: python3 test_mapping.py <spruceOS>/App/PyUI/main-ui  (rg351p.py copied into its devices/darkmoss)
sys.path.insert(0, sys.argv[1])
from controller.controller_inputs import ControllerInput as CI
from controller.key_state import KeyState as KS
from controller.key_watcher_controller_dataclasses import KeyEvent
from devices.darkmoss.rg351p import RG351P, RG351PKeyMappingProvider
dev = RG351P.__new__(RG351P)
p = RG351PKeyMappingProvider(dev._button_mappings())
def ev(t,c,v): r = p.get_mapped_events(KeyEvent(t,c,v)); return [(x.controller_input, x.key_state) for x in (r or [])]
assert ev(3,17,-1) == [(CI.DPAD_UP, KS.PRESS)], ev(3,17,-1)
assert ev(3,17,0) == [(CI.DPAD_UP, KS.RELEASE),(CI.DPAD_DOWN, KS.RELEASE)]
assert ev(3,16,1) == [(CI.DPAD_RIGHT, KS.PRESS)]
assert ev(3,0,30000) == [] and ev(3,1,-30000) == []      # stick ignored
assert ev(1,304,1) == [(CI.A, KS.PRESS)] and ev(1,305,1) == [(CI.B, KS.PRESS)]
assert ev(1,310,1) == [(CI.START, KS.PRESS)]               # START first: no crash
assert ev(1,310,0) == [(CI.START, KS.RELEASE)]
assert ev(1,311,1) == [(CI.SELECT, KS.PRESS)]
assert ev(1,310,1) == [(CI.SELECT, KS.RELEASE),(CI.MENU, KS.PRESS)]   # SELECT+START chord
assert ev(1,310,0) == [(CI.MENU, KS.RELEASE)]
assert ev(1,311,0) == []                                   # SELECT release swallowed
assert ev(1,312,1) == [(CI.MENU, KS.PRESS)] and ev(1,312,0) == [(CI.MENU, KS.RELEASE)]
assert ev(1,313,1) == [(CI.R3, KS.PRESS)]
assert ev(1,314,1) == [(CI.L2, KS.PRESS)] and ev(1,309,1) == [(CI.R1, KS.PRESS)]
print("mapping OK")

# Volume: a hardware wheel after the codec, so the codec is pinned at full.
from devices.darkmoss.darkmoss_device import DarkmossDevice
sent = []
DarkmossDevice._set_volume = lambda self, v: sent.append(v) or v
assert dev.supports_volume() is False
dev._set_volume(35)
assert sent == [100], sent
class _Cfg:
    vol = 50; saved = 0
    def reload_config(self): pass
    def get_volume(self): return self.vol
    def set_volume(self, v): self.vol = v
    def save_config(self): self.saved += 1
dev.system_config = _Cfg()
dev.volume_down()
assert dev.system_config.vol == 100 and sent[-1] == 100
print("volume OK")
