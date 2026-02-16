import json, time, os

def viz(kind, payload):
    """Standard KET VIZ protocol"""
    msg = {"kind": kind, "payload": payload, "ts": int(time.time()*1000)}
    print(f"KET_VIZ {json.dumps(msg, ensure_ascii=False)}", flush=True)

def heatmap(data, title="Heatmap"):
    viz("heatmap", {"data": data, "title": title})

def table(title, rows):
    viz("table", {"title": title, "rows": rows})

def text(content):
    viz("text", {"content": content})

def histogram(counts, title="Counts"):
    viz("quantum", {"histogram": counts, "title": title})

def plot(fig, name="plot.png", title=None):
    out_dir = os.environ.get("KET_OUT", ".")
    if not os.path.exists(out_dir):
        os.makedirs(out_dir)
    path = os.path.join(out_dir, name)
    fig.savefig(path, bbox_inches='tight')
    viz("image", {"path": path, "title": title or name})
    return path

def dashboard(histogram=None, matrix=None):
    """Combine histogram and matrix in one view"""
    viz("quantum", {"histogram": histogram, "matrix": matrix})
