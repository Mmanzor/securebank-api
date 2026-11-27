"""PDFs from the archived ZAP report and documented Checkov runs."""
import json
import sys
from pathlib import Path
from xml.sax.saxutils import escape
from reportlab.lib import colors
from reportlab.lib.enums import TA_JUSTIFY
from reportlab.lib.pagesizes import A4
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.lib.units import mm
from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle, Image, PageBreak

out = Path(sys.argv[1])
out.mkdir(parents=True, exist_ok=True)
source = Path("Docs/Evidencias/Sesion_08")
navy = colors.HexColor("#183B56")
teal = colors.HexColor("#176B73")
styles = getSampleStyleSheet()
styles.add(ParagraphStyle(name="BodyLab", fontName="Helvetica", fontSize=10.5, leading=14, alignment=TA_JUSTIFY, spaceAfter=7))
styles.add(ParagraphStyle(name="SmallLab", fontName="Helvetica", fontSize=9, leading=12, spaceAfter=4))
styles.add(ParagraphStyle(name="CellLab", fontName="Helvetica", fontSize=9, leading=11))
styles.add(ParagraphStyle(name="HeadLab", fontName="Helvetica-Bold", fontSize=9, leading=11, textColor=colors.white))
styles.add(ParagraphStyle(name="TitleLab", fontName="Helvetica-Bold", fontSize=23, leading=27, textColor=navy, spaceAfter=10))
styles.add(ParagraphStyle(name="SubLab", fontName="Helvetica-Bold", fontSize=13, leading=17, textColor=teal, spaceBefore=8, spaceAfter=6))
def p(s, style="BodyLab"):
    return Paragraph(s, styles[style])
def table(rows, widths):
    data = [[p(escape(str(v)), "HeadLab" if i == 0 else "CellLab") for v in row] for i, row in enumerate(rows)]
    t = Table(data, colWidths=widths, repeatRows=1, hAlign="LEFT")
    t.setStyle(TableStyle([
        ("BACKGROUND",(0,0),(-1,0),navy),("ROWBACKGROUNDS",(0,1),(-1,-1),[colors.white,colors.HexColor("#EFF5F7")]),
        ("VALIGN",(0,0),(-1,-1),"TOP"),("TOPPADDING",(0,0),(-1,-1),7),("BOTTOMPADDING",(0,0),(-1,-1),7),
        ("LINEBELOW",(0,-1),(-1,-1),0.5,colors.HexColor("#CBD7DD"))
    ]))
    return t
def header(c, doc):
    w,h=A4
    c.setFillColor(navy); c.setFont("Helvetica-Bold",9)
    c.drawString(19*mm,h-14*mm,"SECUREPIPELINE  /  SISTEMAS AUTOMATIZADOS DEVSECOPS")
    c.setStrokeColor(teal); c.line(19*mm,h-17*mm,w-19*mm,h-17*mm)
    c.setFillColor(colors.HexColor("#536773"));c.setFont("Helvetica",8)
    c.drawString(19*mm,12*mm,"Universidad Bernardo O'Higgins  /  SecureBank API")
    c.drawRightString(w-19*mm,12*mm,str(doc.page))
def pdf(name, story):
    doc=SimpleDocTemplate(str(out/name),pagesize=A4,leftMargin=19*mm,rightMargin=19*mm,topMargin=24*mm,bottomMargin=20*mm)
    doc.build(story,onFirstPage=header,onLaterPages=header)
def link(label,url):
    return p(f'<link href="{escape(url)}" color="#176B73">{escape(label)}</link>',"SmallLab")
def shot(path, width=168*mm, maxheight=82*mm):
    im=Image(str(path)); scale=min(width/im.imageWidth,maxheight/im.imageHeight)
    im.drawWidth=im.imageWidth*scale; im.drawHeight=im.imageHeight*scale
    return im

baseline=json.loads((source/"report.json").read_text(encoding="utf-8"))
openapi=json.loads((source/"zap-openapi.json").read_text(encoding="utf-8"))
alerts=[a for s in baseline["site"] for a in s["alerts"]]
rows=[["Severidad","CWE","URL / ruta","Hallazgo y evidencia"]]
for a in alerts:
    paths=[i["uri"].split(":3001",1)[-1] or "/" for i in a["instances"]]
    evidence=sorted({i.get("evidence","") for i in a["instances"]})
    rows.append([a["riskdesc"],a["cweid"],", ".join(paths),a["name"]+"; "+", ".join(evidence)])
dast=[
    p("01 / Reporte DAST","TitleLab"),
    p("OWASP ZAP Baseline y plan OpenAPI | análisis histórico del laboratorio","SmallLab"),
    p("El análisis pasivo se efectuó sobre una instancia Docker de SecureBank API. El informe baseline nativo registra "+escape(baseline["@generated"])+", versión "+escape(baseline["@version"])+". El plan OpenAPI posterior registra "+escape(openapi["@generated"])+", con alcance distinto."),
    table(rows,[31*mm,14*mm,45*mm,80*mm]),Spacer(1,7*mm),
    p("Panel nativo de ZAP","SubLab"),
]
if (out/"zap-dashboard.png").exists():
    dast += [shot(out/"zap-dashboard.png"),p("Captura renderizada del HTML original archivado; no corresponde a un nuevo escaneo.","SmallLab")]
else:
    dast += [p("La captura del HTML no pudo recuperarse en esta ejecución. Se conserva el reporte HTML original como evidencia independiente.")]
dast += [
    p("No se detectaron alertas de severidad alta o media en el baseline archivado. Medium en Informational (Medium) es el nivel de confianza."),
    PageBreak(),p("02 / Plan de mitigación","TitleLab"),
    p("Acciones, responsables y verificación de los controles"),
    table([["Hallazgo / control","Acción","Responsable / plazo","Verificación"],
          ["Cache-Control: no-store","Mantener; evita almacenamiento de respuestas sensibles","Backend / próximo ciclo","Revisar header y nuevo escaneo"],
          ["BOLA / users/{id}","Comprobar identidad y propiedad del objeto","Backend y QA / cada cambio","401 sin identidad, 403 ajeno, 200 propio"],
          ["Cabeceras y cookies","Mantener cabeceras; API de prueba no emite cookies de sesión","Backend / próximo ciclo","Pruebas HTTP y reescaneo"]],[38*mm,48*mm,40*mm,44*mm]),
    p("Alcance y reproducibilidad","SubLab"),
    p("Los tokens son ficticios, sin autenticación de producción. El plan OpenAPI posterior registró cero alertas; no se afirma que sea un reescaneo idéntico ni que toda la aplicación sea segura."),
    p("Comando versionado del plan CI: docker run --rm --network host -v \"$PWD:/zap/wrk:rw\" ghcr.io/zaproxy/zaproxy:stable zap.sh -cmd -autorun /zap/wrk/zap-openapi-ci.yaml","SmallLab"),
    p("El comando exacto del baseline histórico no consta en el material archivado. Se conserva el JSON original sin modificaciones."),
    link("Run DAST de referencia","https://github.com/Mmanzor/securebank-api/actions/runs/44647102958"),
    link("HTML y JSON originales","https://github.com/Mmanzor/securebank-api/tree/main/Docs/Evidencias/Sesion_08"),
]
pdf("reporte-dast-SecurePipeline.pdf",dast)
iac=[
    p("01 / Auditoría de infraestructura","TitleLab"),
    p("Terraform y Checkov 3.4.11 | ejecución histórica del laboratorio","SmallLab"),
    p("Se modelaron veinte elementos principales de la pauta y recursos auxiliares. La línea base reconstruida y el módulo corregido se analizaron con la misma versión de Checkov. La clasificación de severidades corresponde a la política local, no a Prisma Cloud."),
    table([["Métrica","Inicial","Corregido"],["Controles aprobados","152","174"],["Controles fallidos","33","11"],["Críticos según política local","4","0"],["Altos según política local","18","0"],["Security Score","82,16 %","94,05 %"]],[100*mm,35*mm,35*mm]),
    p("Cinco correcciones prioritarias","SubLab"),
    table([["Control","Debilidad","Corrección"],
          ["CKV_AWS_24","SSH expuesto","CIDR interno; EC2 sin IP pública"],
          ["CKV2_AWS_6 / CKV_AWS_53-56","Acceso público S3","Bloqueos en ambos buckets; SSE-KMS en backups"],
          ["CKV_AWS_16","RDS sin cifrado","KMS y subredes privadas"],
          ["CKV_AWS_62","IAM excesivo","Permisos acotados a prefijo y grupo de logs"],
          ["CKV_AWS_251","Auditoría insuficiente","CloudTrail y VPC Flow Logs con destinos cifrados"]],[44*mm,45*mm,81*mm]),
    PageBreak(),p("02 / Gate y validación","TitleLab"),
    p("El Security Score divide los aprobados entre aprobados más fallidos. La puntuación final supera el mínimo docente de 85 %. Permanecen once hallazgos residuales, clasificados conforme a la política local."),
    p("Evidencia de ejecución histórica","SubLab"),
    table([["Etapa del run 45727010153","Estado"],["Checkov: scan y gate","Success"],["Terraform: plan sin AWS","Success"],["Terraform: apply simulado","Success"]],[119*mm,51*mm]),
    p("Estados contrastados con los jobs publicados por GitHub Actions. Esta tabla no es una captura de pantalla de la plataforma.","SmallLab"),
]
if (out/"iac-pipeline.png").exists():
    iac += [shot(out/"iac-pipeline.png",maxheight=85*mm),p("Captura de la página histórica de GitHub Actions.","SmallLab")]
iac += [
    p("El gate rechazó la línea base con hallazgos críticos y permitió el módulo corregido. Se ejecutó plan y apply con proveedor AWS simulado: no se crearon recursos ni cargos."),
    link("Run negativo: gate bloqueado","https://github.com/Mmanzor/securebank-api/actions/runs/45726588055"),
    link("Run positivo: gate, plan y apply","https://github.com/Mmanzor/securebank-api/actions/runs/45727010153"),
    link("Reportes nativos de Checkov","https://github.com/Mmanzor/securebank-api/actions/runs/45727010153/artifacts/15074019156"),
    link("Código y reproducción","https://github.com/Mmanzor/securebank-api/tree/main/terraform"),
]
pdf("informe-iac-SecurePipeline.pdf",iac)
