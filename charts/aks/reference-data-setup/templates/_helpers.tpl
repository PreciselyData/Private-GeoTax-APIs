{{/*
Geotax reference data Storage Class
*/}}
{{- define "geotax-ref-storage-class.name" -}}
{{- printf "%s-%s" "ref-efs-aks" .Release.Name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Geotax reference data Persistent Volume Name
*/}}
{{- define "geotax-ref-pv.name" -}}
{{- printf "%s-%s-%s" "ref-aks" .Release.Name "pv" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Geotax reference data Persistent Volume Claim Name
*/}}
{{- define "geotax-ref-pvc.name" -}}
{{- printf "%s-%s-%s" "ref-aks" .Release.Name "pvc" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Geotax reference data PV labels
*/}}
{{- define "geotax-ref-pv.labels" -}}
app.kubernetes.io/name: {{ include "geotax-ref-pv.name" . }}
app.kubernetes.io/managed-by: Precisely
app.kubernetes.io/instance: {{ .Release.Name }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
{{- end }}

{{/*
Geotax reference data PVC labels
*/}}
{{- define "geotax-ref-pvc.labels" -}}
app.kubernetes.io/name: {{ include "geotax-ref-pvc.name" . }}
app.kubernetes.io/managed-by: Precisely
app.kubernetes.io/instance: {{ .Release.Name }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
{{- end }}