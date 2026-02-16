import sys
import os
import json

# --- KET IDE INTERCEPTOR ---
try:
    import matplotlib
    matplotlib.use('Agg')
    import matplotlib.pyplot as plt
    
    def ket_show(*args, **kwargs):
        import time
        vdir = os.environ.get("KET_OUT", ".")
        if not os.path.exists(vdir):
            os.makedirs(vdir)
        path = os.path.join(vdir, f"viz_{int(time.time()*1000)}.png")
        plt.savefig(path, bbox_inches='tight')
        print(f"IMAGE:{path}")
        plt.close()
    
    import matplotlib.figure
    def ket_fig_show(self, *args, **kwargs):
        import time
        vdir = os.environ.get("KET_OUT", ".")
        if not os.path.exists(vdir):
            os.makedirs(vdir)
        path = os.path.join(vdir, f"viz_{int(time.time()*1000)}.png")
        self.savefig(path, bbox_inches='tight')
        print(f"IMAGE:{path}")
    
    plt.show = ket_show
    matplotlib.figure.Figure.show = ket_fig_show
except Exception:
    pass

# Run user script
import runpy
try:
    target_script = sys.argv[1]
    sys.argv = sys.argv[1:]
    runpy.run_path(target_script, run_name="__main__")
except Exception as e:
    import traceback
    traceback.print_exc()
