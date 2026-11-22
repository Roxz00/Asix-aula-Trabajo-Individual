#!/usr/bin/env python3
"""Genera el PDF de entrega de una tarea a partir de sus documentos Markdown.

Uso:  python3 scripts/generar-lliurament.py 0 2 4      (o «todas»)
Salida: lliuraments/TascaN_Lliurament_Individual.pdf

Cada PDF lleva una portada (como las del grupo) con el enlace al repositorio y dónde está la tarea,
y después el contenido completo de los documentos. Los enlaces relativos se convierten en enlaces
de GitHub para que funcionen dentro del PDF. Los diagramas Mermaid se dibujan con mermaid.js.
Necesita: python3-markdown y google-chrome (o chromium).
"""
import html, pathlib, re, shutil, subprocess, sys, tempfile
import markdown

REPO = pathlib.Path(__file__).resolve().parent.parent
GITHUB = "https://github.com/Roxz00/Asix-aula-Trabajo-Individual"
GRUPO = "https://github.com/varo010/asix-aula-grup-03-ISO"

TAREAS = {
    0: dict(titulo="Montaje del entorno de pruebas",
            resumen="El entorno de pruebas montado en VirtualBox en mi equipo: qué máquinas hay, qué recursos "
                    "tiene cada una, cuántas caben a la vez y los problemas encontrados con su solución.",
            docs=["docs/00-entorno-pruebas.md", "docs/05-recursos.md"],
            donde=[("docs/00-entorno-pruebas.md", "montaje, verificación, escenarios y problemas"),
                   ("docs/05-recursos.md", "tabla de máquinas, requisitos oficiales y recursos simultáneos"),
                   ("diagrames/", "esquema de las máquinas virtuales")]),
    2: dict(titulo="Equipos y periféricos",
            resumen="Inventario del PC de casa y del PC de clase, comparativa, cuellos de botella con sus "
                    "soluciones y tests de memoria, disco y red que los confirman o los descartan.",
            docs=["docs/02-inventari.md"],
            donde=[("docs/02-inventari.md", "inventario, comparativa, cuellos de botella y tests"),
                   ("scripts/inventario-diagnostico.sh", "el script que recoge los datos"),
                   ("evidencies/", "las salidas completas (t2-*)")]),
    4: dict(titulo="Diseño físico y lógico",
            resumen="El esquema de red del entorno individual, la configuración de cada interfaz y la "
                    "comprobación de la conectividad con ping, traceroute y tablas de rutas.",
            docs=["docs/04-disseny.md", "diagrames/esquema-individual.md"],
            donde=[("docs/04-disseny.md", "plan de direcciones, interfaces y verificación"),
                   ("diagrames/", "esquema lógico individual (Mermaid) y referencia del grupo"),
                   ("evidencies/", "las salidas de la verificación (t4-*)")]),
    5: dict(titulo="Instalación y comunicaciones",
            resumen="Los sistemas instalados en el entorno individual y cómo están configurados: "
                    "comunicaciones, NAS, clúster, dominio y clientes, con sus copias y sus pruebas.",
            docs=["docs/05-installacions.md"],
            donde=[("docs/05-installacions.md", "el documento completo, sistema a sistema"),
                   ("configs/", "configuraciones exportadas de cada equipo"),
                   ("evidencies/", "el estado leído de cada equipo (t5-*)")]),
    6: dict(titulo="Almacenamiento y recuperación",
            resumen="Tres tipos de RAID creados y probados en el entorno individual, qué aporta cada uno y "
                    "qué pasa cuando falla un disco, y un espejo entre dos equipos (cliente Debian y NAS por iSCSI).",
            docs=["docs/06-recuperacio.md"],
            donde=[("docs/06-recuperacio.md", "el documento completo"),
                   ("scripts/t6-raid.sh", "el script de las pruebas"),
                   ("decisions/D-09-espejo-entre-equipos-iscsi.md", "por qué el espejo se hace con iSCSI"),
                   ("evidencies/", "los comandos y sus salidas (t6-*)")]),
    7: dict(titulo="Rendimiento y diagnóstico",
            resumen="Análisis de los recursos del PC con distintas cargas de VMs: qué se satura, cuántas VMs "
                    "se pueden usar sin bloquear el equipo y optimizaciones medidas antes y después.",
            docs=["docs/07-rendiment.md"],
            donde=[("docs/07-rendiment.md", "el documento completo"),
                   ("evidencies/", "las medidas tal como salieron (t7-*)")]),
}

CSS = """
@page { size: A4; margin: 18mm 16mm 18mm 16mm; }
body { font-family: 'Noto Sans', 'DejaVu Sans', sans-serif; font-size: 10pt; color: #1f2733; line-height: 1.45; }
.portada { height: 255mm; display: flex; flex-direction: column; page-break-after: always; }
.kicker { color: #2f6fd6; font-weight: 700; font-size: 9pt; letter-spacing: .6px; }
.portada h1 { font-size: 30pt; line-height: 1.12; margin: 16px 0 10px; }
.portada .resumen { font-size: 13pt; color: #555; max-width: 150mm; }
.caja { margin-top: auto; background: #e9f0fb; border-radius: 8px; padding: 14px 18px; }
.caja a.repo { font-size: 14pt; font-weight: 700; }
.pie { border-top: 1px solid #ccc; margin-top: 28px; padding-top: 6px; font-size: 8pt; color: #777; }
h1 { font-size: 18pt; margin: 0 0 6px; } h2 { font-size: 14pt; margin: 18px 0 6px; page-break-after: avoid; }
h3 { font-size: 11.5pt; margin: 14px 0 4px; page-break-after: avoid; }
a { color: #2f6fd6; text-decoration: none; }
table { border-collapse: collapse; width: 100%; margin: 8px 0 12px; font-size: 8.6pt; page-break-inside: auto; }
tr { page-break-inside: avoid; }
th { background: #f0f2f5; text-align: left; font-weight: 600; color: #444; }
th, td { border-bottom: 1px solid #dde1e6; padding: 4px 6px; vertical-align: top; }
code { font-family: 'DejaVu Sans Mono', monospace; font-size: 8.4pt; background: #f2f3f5; padding: 0 3px; border-radius: 3px; }
pre { background: #f6f7f9; border: 1px solid #e1e4e8; border-radius: 6px; padding: 8px 10px; font-size: 8pt;
      white-space: pre-wrap; page-break-inside: avoid; }
pre code { background: none; padding: 0; }
blockquote { margin: 8px 0; padding: 6px 12px; background: #f6f4ef; border-left: 4px solid #d9c9a3; color: #444; }
.doc { page-break-before: always; } .doc:first-of-type { page-break-before: auto; }
.mermaid { text-align: center; margin: 10px 0; }
"""

def enlaces_a_github(texto, origen):
    """Convierte los enlaces relativos (a.md, ../evidencies/x) en enlaces absolutos de GitHub."""
    base = (REPO / origen).parent
    def cambia(m):
        etiqueta, destino = m.group(1), m.group(2)
        if re.match(r"^(https?:|mailto:|#)", destino):
            return m.group(0)
        ruta, _, ancla = destino.partition("#")
        absoluta = (base / ruta).resolve()
        if not absoluta.exists():      # no es un enlace (p. ej. «sde[1](F)» de /proc/mdstat dentro de código)
            return m.group(0)
        rel =absoluta.relative_to(REPO).as_posix()
        tipo = "tree" if absoluta.is_dir() else "blob"
        return f"[{etiqueta}]({GITHUB}/{tipo}/main/{rel}{'#' + ancla if ancla else ''})"
    return re.sub(r"\[([^\]]*)\]\(([^)\s]+)\)", cambia, texto)

def md_a_html(ruta):
    texto = (REPO / ruta).read_text(encoding="utf-8")
    texto = enlaces_a_github(texto, ruta)
    # En la cabecera (cita de las primeras líneas) cada línea es un dato: se respeta el salto de línea
    lineas = texto.split("\n")
    for i, l in enumerate(lineas[:12]):
        if l.startswith("> ") and i + 1 < len(lineas) and lineas[i + 1].startswith("> "):
            lineas[i] = l + "  "
    texto = "\n".join(lineas)
    # Bloques Mermaid: se dejan como <div class="mermaid"> para mermaid.js
    texto = re.sub(r"```mermaid\n(.*?)```", lambda m: f'<div class="mermaid">\n{html.escape(m.group(1))}</div>',
                   texto, flags=re.S)
    return markdown.markdown(texto, extensions=["tables", "fenced_code", "sane_lists", "md_in_html"])

def portada(n, t):
    items = "".join(f'<li><a href="{GITHUB}/{"tree" if d.endswith("/") else "blob"}/main/{d}">{d}</a>: {html.escape(q)}</li>'
                    for d, q in t["donde"])
    return f"""<section class="portada">
<div class="kicker">IMPLANTACIÓ DE SISTEMES OPERATIUS · ASIX THINKLAB · GRUPO 3</div>
<h1>Lliurament individual<br>Tasca {n} · {html.escape(t['titulo'])}</h1>
<div class="resumen">{html.escape(t['resumen'])}</div>
<div class="caja"><b>Repositorio individual (toda la documentación):</b><br>
<a class="repo" href="{GITHUB}">{GITHUB}</a>
<p>La Tasca {n} está en:</p><ul>{items}</ul>
<p style="font-size:8.5pt;color:#555">Entorno individual en VirtualBox sobre Linux Mint (disco externo). Simula el montaje
del grupo, documentado en <a href="{GRUPO}">{GRUPO}</a>.</p></div>
<div class="pie">Parte individual · Grupo 3 · Red 192.168.30.0/24 · Noviembre de 2026<br>
El montaje y las pruebas se hicieron en mi entorno; Claude (asistente de IA) ayudó a ejecutar las órdenes,
interpretar los resultados y redactar la documentación.</div></section>"""

def generar(n):
    t = TAREAS[n]
    faltan = [d for d in t["docs"] if not (REPO / d).exists()]
    if faltan:
        print(f"Tasca {n}: faltan {faltan}, no se genera"); return
    cuerpo = "".join(f'<section class="doc">{md_a_html(d)}</section>' for d in t["docs"])
    mermaid = ""
    if "mermaid" in cuerpo:
        mermaid = ('<script src="https://cdn.jsdelivr.net/npm/mermaid@10.9.1/dist/mermaid.min.js"></script>'
                   '<script>mermaid.initialize({startOnLoad:true, theme:"neutral", flowchart:{useMaxWidth:true}});</script>')
    doc = f"""<!doctype html><html lang="es"><head><meta charset="utf-8"><title>Tasca {n} · Lliurament individual</title>
<style>{CSS}</style></head><body>{portada(n, t)}{cuerpo}{mermaid}</body></html>"""
    salida = REPO / "lliuraments" / f"Tasca{n}_Lliurament_Individual.pdf"
    salida.parent.mkdir(exist_ok=True)
    navegador = shutil.which("google-chrome") or shutil.which("chromium") or shutil.which("chromium-browser")
    with tempfile.TemporaryDirectory() as tmp:
        h = pathlib.Path(tmp) / "t.html"; h.write_text(doc, encoding="utf-8")
        subprocess.run([navegador, "--headless=new", "--disable-gpu", "--no-pdf-header-footer",
                        "--virtual-time-budget=15000", f"--user-data-dir={tmp}/perfil",
                        f"--print-to-pdf={salida}", h.as_uri()],
                       check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    print(f"✔ {salida.relative_to(REPO)}")

if __name__ == "__main__":
    pedidas = sorted(TAREAS) if sys.argv[1:] in ([], ["todas"]) else [int(a) for a in sys.argv[1:]]
    for n in pedidas:
        generar(n)
